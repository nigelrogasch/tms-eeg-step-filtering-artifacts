function x_filt = tesa_highpass_edge_step(x, fs, varargin)
% REMOVE_STEP_AND_HIGHPASS_WITH_DRIFT_3D
% Removes step artifact and optionally polynomial trend from multi-trial EEG data,
% then applies a high-pass Butterworth filter with mirror padding.
%
%   x:  channels x time x trials
%   fs: sampling rate (Hz)
%
% Optional parameters (passed as key/value pairs):
%   'StepDetectionThreshold' - multiplier of MAD for step detection (default = 8)
%   'HighpassCutoff'          - high-pass filter cutoff in Hz (default = 1)
%   'FilterOrder'             - Butterworth filter order (default = 4)
%   'PadLength'               - padding length in seconds for filtering (default = 10)
%   'DetrendOrder'            - polynomial order for drift removal (default = 1)
%   'Robust'                  - use robust regression for step/drift removal (default = true)
%   'StepIndex'               - index (or vector of indices) where step(s) occur (default = [])
%   'RemoveTrend'             - logical, whether to subtract polynomial trend (default = false)
%   'RemoveStep'              - logical, whether to subtract detected or provided step(s) (default = true)
%
% Example:
%   x_filt = remove_step_and_highpass_with_drift_3d(eeg, 1000, ...
%                 'RemoveStep', false, 'RemoveTrend', true, 'HighpassCutoff', 0.5);

%% --- Parse inputs ---
p = inputParser;
addParameter(p, 'StepDetectionThreshold', 8);
addParameter(p, 'HighpassCutoff', 1);
addParameter(p, 'FilterOrder', 4);
addParameter(p, 'PadLength', 10);
addParameter(p, 'DetrendOrder', 1);
addParameter(p, 'Robust', true);
addParameter(p, 'StepIndex', []);
addParameter(p, 'RemoveTrend', false);
addParameter(p, 'RemoveStep', true);
parse(p, varargin{:});
params = p.Results;

[chN, tN, trN] = size(x);
x_filt = nan(size(x));

% Design Butterworth high-pass filter
[b, a] = butter(params.FilterOrder, params.HighpassCutoff/(fs/2), 'high');

for tr = 1:trN
    X_trial = squeeze(x(:,:,tr));

    % Step detection or user-provided step index (only if RemoveStep is true)
    if params.RemoveStep
        if isempty(params.StepIndex)
            d = median(abs(diff(double(X_trial),1,2)),1);
            d_thresh = params.StepDetectionThreshold * median(d);
            [~, step_idx] = max(d);
            if d(step_idx) < d_thresh
                step_idx = [];
            end
        else
            step_idx = params.StepIndex;
        end
    else
        step_idx = [];
    end

    % Prepare clean data
    X_clean = X_trial;
    t = (0:tN-1)'/fs;

    for ch = 1:chN
        y = double(X_trial(ch,:))';
        reg = [];

        % Step regressors only if RemoveStep true and steps exist
        if params.RemoveStep && ~isempty(step_idx)
            for si = 1:numel(step_idx)
                step_reg = zeros(tN,1);
                step_reg(step_idx(si):end) = 1;
                reg = [reg step_reg];
            end
        end

        % Drift regressors only if RemoveTrend true
        drift_reg = [];
        if params.RemoveTrend
            for k = 1:params.DetrendOrder
                drift_reg = [drift_reg t.^k];
            end
            reg = [reg drift_reg];
        end

        if ~isempty(reg)
            if params.Robust
                b_reg = robustfit(reg, y);
                y = y - (b_reg(1) + reg * b_reg(2:end));
            else
                b_reg = reg \ y;
                y = y - reg * b_reg;
            end
        end
        X_clean(ch,:) = y';
    end

    % Mirror padding
    pad_n = min(round(params.PadLength * fs), tN-1);
    X_pad = [fliplr(X_clean(:,1:pad_n)), X_clean, fliplr(X_clean(:,end-pad_n+1:end))];

    % Zero-phase Butterworth filtering
    X_pad_filt = filtfilt(b, a, double(X_pad') )';

    % Remove padding
    x_filt(:,:,tr) = X_pad_filt(:, pad_n+1 : pad_n+tN);
end
end