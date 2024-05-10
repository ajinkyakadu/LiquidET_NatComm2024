function varargout = crop_stack(varargin)
% Displays a graphical interface for cropping tilt series using rectangular ROI.
%
% Displays either maximum projection or average of all images in a stack.
% Allows to specify a rectangular ROI. Upon pressing "Apply" or <Enter> key,
% returns the stack cropped around the ROI. Pressing <Escape> or closing the
% figure aborts the operation and returns the original stack.
%
% Parameters:
%   in (3D array)
%   rect (1D array, optional):
%     Vector specifying the ROI to use in the following format:
%     [x_min, y_min, width, height]. If omitted a GUI for interactive ROI
%     selection is invoked.
%
% Returns:
%   cropped (3D array)
%   rect (1D array):
%     Used ROI specified as [x_min, y_min, width, height].
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023


% Apply ROI immediately if it is already specified
if length(varargin) > 1 && ~ischar(varargin{1})
    stack = varargin{1};
    rect = varargin{2};
    varargout{1} = apply_roi(stack, rect);
    varargout{2} = rect;
    return
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @crop_stack_OpeningFcn, ...
                   'gui_OutputFcn',  @crop_stack_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function crop_stack_OpeningFcn(hObject, ~, handles, varargin)
    handles.stack = varargin{1};
    handles.stack_init = handles.stack; % Keep a copy to restore if needed

    % Start with Maximum Intensity Projection
    handles.projection = imshow(max(handles.stack, [], 3), [], ...
                             'Parent', handles.proj_axes);

    % Place a resizable rectangular ROI
    title(handles.proj_axes, 'Position/resize the rectangular ROI and click Apply')
    [nx, ny, ~] = size(handles.stack);
    if verLessThan('matlab', '9.5')
        handles.roi = imrect(handles.proj_axes, round([nx/5, ny/5 3*nx/5 3*ny/5]));
    else
        handles.roi = drawrectangle(handles.proj_axes, ...
                                   'Position', round([nx/5, ny/5 3*nx/5 3*ny/5]));
    end

    guidata(hObject, handles);
    uiwait(handles.main_figure);


function varargout = crop_stack_OutputFcn(hObject, ~, handles)
    varargout{1} = handles.stack;
    varargout{2} = handles.rect;
    delete(hObject);


function avg_proj_radio_Callback(~, ~, handles)
    update_projection(handles);


function mip_radio_Callback(~, ~, handles)
    update_projection(handles);


function apply_button_Callback(hObject, ~, handles)
    if verLessThan('matlab', '9.5')
        handles.rect = handles.roi.getPosition();
    else
        handles.rect = handles.roi.Position;
    end
    handles.stack = apply_roi(handles.stack, handles.rect);
    guidata(hObject, handles);
    uiresume(handles.main_figure);


function main_figure_CloseRequestFcn(hObject, ~, handles)
    handles.stack = handles.stack_init;
    handles.rect = [];
    guidata(hObject, handles);
    uiresume(handles.main_figure);


function main_figure_KeyPressFcn(hObject, eventdata, handles)
key = hObject.CurrentKey;
if ismember(key, {'escape'})
    figure1_CloseRequestFcn(hObject, eventdata, handles);
elseif ismember(key, {'return'})
    apply_button_Callback(hObject, eventdata, handles);
end


function update_projection(handles)
    if handles.mip_radio.Value
        handles.projection.CData = max(handles.stack, [], 3);
    else
        handles.projection.CData = mean(handles.stack, 3);
    end

 function cropped = apply_roi(stack, rect)
     xmin = round(rect(1));
     ymin = round(rect(2));
     width = round(rect(3));
     height = round(rect(4));
     cropped = stack(ymin:(ymin + height - 1), xmin:(xmin + width - 1), :);