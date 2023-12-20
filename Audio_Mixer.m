classdef Audio_Mixer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        ExportMixedAudioButton      matlab.ui.control.StateButton
        ExportButton                matlab.ui.control.Button
        EditField                   matlab.ui.control.EditField
        PlotMixedAudioButton        matlab.ui.control.Button
        ResetMixedAudioButton       matlab.ui.control.Button
        PlayMixedAudioButton        matlab.ui.control.Button
        AddSampleButton             matlab.ui.control.Button
        StopSampleButton            matlab.ui.control.Button
        PlaySampleButton            matlab.ui.control.Button
        SampleEndEditField          matlab.ui.control.NumericEditField
        SampleEndEditFieldLabel     matlab.ui.control.Label
        SampleStartEditField        matlab.ui.control.NumericEditField
        SampleStartEditFieldLabel   matlab.ui.control.Label
        Slider_4                    matlab.ui.control.Slider
        Slider_3                    matlab.ui.control.Slider
        StopButton                  matlab.ui.control.Button
        PlayButton                  matlab.ui.control.Button
        AudioSelectorDropDown       matlab.ui.control.DropDown
        AudioSelectorDropDownLabel  matlab.ui.control.Label
        ImportButton                matlab.ui.control.Button
        UIAxes2                     matlab.ui.control.UIAxes
        UIAxes                      matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        path
        audiofile % Audio File
        fs
        player % Player Object
        sample_player
        sample_audio_data
        sample_audio_fs
        final_player
        audio_samples = []
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ImportButton
        function ImportButtonPushed(app, event)
            app.AudioSelectorDropDown.Enable = "off";
            try
                [files, app.path] = uigetfile({'*.wav; *.mp3; *.avi', "Audio Files (*.wav, *.mp3, *.avi)"},"MultiSelect", "on", "Audio Files Selector");
                [~ , num_of_items] = size(files);
                if (num_of_items)
                    app.AudioSelectorDropDown.Enable = "on";
                    app.AudioSelectorDropDown.Items = files;
                end
            catch
                uialert(app.UIFigure,"Select more than one file", "Selection Error")
            end
        end

        % Value changed function: AudioSelectorDropDown
        function AudioSelectorDropDownValueChanged(app, event)
            app.UIAxes.Visible = "on";
            app.UIAxes2.Visible = "on";
            value = app.AudioSelectorDropDown.Value;
            [app.audiofile, app.fs] = audioread(value);
            app.player = audioplayer(app.audiofile, app.fs);
            plot(app.UIAxes, app.audiofile(:,1), Color="#D95319");
            xlim(app.UIAxes, [0, length(app.audiofile)]);
            disableDefaultInteractivity(app.UIAxes)
            disableDefaultInteractivity(app.UIAxes2)
            plot(app.UIAxes2, app.audiofile(:,2), Color="#D95319");
            xlim(app.UIAxes2, [0, length(app.audiofile)]);
            app.Slider_3.Visible = "on";
            app.Slider_4.Visible = "on";
            app.Slider_3.Limits = [0,length(app.audiofile)];
            app.Slider_3.Value = 0;
            app.Slider_4.Limits = [0,length(app.audiofile)];
            app.Slider_4.Value = length(app.audiofile);
            app.SampleStartEditField.Visible = "on";
            app.SampleEndEditField.Visible = "on";
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if (app.AudioSelectorDropDown.Value)
                play(app.player);
            end
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            try 
                if (get(app.player, "Running") == "on")
                    stop(app.player);
                end
            catch
                uialert(app.UIFigure, "No audio file is playing right now", "Audio Player Error")
            end
        end

        % Value changing function: Slider_3
        function Slider_3ValueChanging(app, event)
            changingValue = event.Value;
            app.SampleStartEditField.Value = round(changingValue);

            if((app.SampleStartEditField.Value<=app.SampleEndEditField.Value) && (app.SampleStartEditField.Value~=0) && (app.SampleEndEditField.Value~=0))
                app.PlaySampleButton.Visible = "on";
                app.StopSampleButton.Visible = "on";
                app.AddSampleButton.Visible = "on";
            else
                app.PlaySampleButton.Visible = "off";
                app.StopSampleButton.Visible = "off";
                app.AddSampleButton.Visible = "off";
            end
        end

        % Value changing function: Slider_4
        function Slider_4ValueChanging(app, event)
            changingValue = event.Value;
            app.SampleEndEditField.Value = round(changingValue);

            if((app.SampleStartEditField.Value<=app.SampleEndEditField.Value) && (app.SampleStartEditField.Value~=0) && (app.SampleEndEditField.Value~=0))
                app.PlaySampleButton.Visible = "on";
                app.StopSampleButton.Visible = "on";
                app.AddSampleButton.Visible = "on";
            else
                app.PlaySampleButton.Visible = "off";
                app.StopSampleButton.Visible = "off";
                app.AddSampleButton.Visible = "off";
            end
        end

        % Button pushed function: PlaySampleButton
        function PlaySampleButtonPushed(app, event)
            [sampleaudio, sfs] = audioread(strcat(app.path, app.AudioSelectorDropDown.Value), [round(app.SampleStartEditField.Value),round(app.SampleEndEditField.Value)]);
            app.sample_player = audioplayer(sampleaudio, sfs);
            play(app.sample_player);
        end

        % Button pushed function: StopSampleButton
        function StopSampleButtonPushed(app, event)
            try 
                if (get(app.sample_player, "Running") == "on")
                    stop(app.sample_player);
                end
            catch
                uialert(app.UIFigure, "No audio file is playing right now", "Audio Player Error")
            end
        end

        % Button pushed function: AddSampleButton
        function AddSampleButtonPushed(app, event)
            [app.sample_audio_data, app.sample_audio_fs] = audioread(strcat(app.path, app.AudioSelectorDropDown.Value), [round(app.SampleStartEditField.Value),round(app.SampleEndEditField.Value)]);
            if(isempty(app.audio_samples))
                app.audio_samples = app.sample_audio_data;
                app.PlayMixedAudioButton.Visible = "on";
                app.ResetMixedAudioButton.Visible = "on";
                app.PlotMixedAudioButton.Visible = "on";
                app.ExportMixedAudioButton.Visible = "on";
            else
                app.audio_samples = [app.audio_samples; app.sample_audio_data];
            end
        end

        % Button pushed function: PlayMixedAudioButton
        function PlayMixedAudioButtonPushed(app, event)
            sound(app.audio_samples, app.sample_audio_fs);
        end

        % Button pushed function: ResetMixedAudioButton
        function ResetMixedAudioButtonPushed(app, event)
            app.audio_samples = [];
            app.PlayMixedAudioButton.Visible = "off";
            app.ResetMixedAudioButton.Visible = "off";
            app.PlotMixedAudioButton.Visible = "off";
            app.ExportMixedAudioButton.Visible = "off";
        end

        % Button pushed function: PlotMixedAudioButton
        function PlotMixedAudioButtonPushed(app, event)
            PlotFig = uifigure("Name", "Final Audio Plot");
            channel1 = uiaxes(PlotFig);
            plot(channel1, app.audio_samples(:,1), Color="#D95319");
            xlim(channel1, [0, length(app.audio_samples)]);
        end

        % Value changed function: ExportMixedAudioButton
        function ExportMixedAudioButtonValueChanged(app, event)
            value = app.ExportMixedAudioButton.Value;
            if(value==1)
                app.EditField.Visible = "on";
                app.ExportButton.Visible = "on";
            else
                app.EditField.Visible = "off";
                app.ExportButton.Visible = "off";
            end
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
            filename = app.EditField.Value;
            if (length(filename)>0)
                audiowrite(strcat(filename, ".mp3"), app.audio_samples, app.sample_audio_fs);
                uialert(app.UIFigure, "Final Audio had been exported", "Export Successful")
                app.PlayMixedAudioButton.Visible = "off";
                app.ExportButton.Visible = "off";
                app.ExportMixedAudioButton.Value = 0;
                app.ExportMixedAudioButton.Visible = "off";
                app.EditField.Visible = "off";
                app.ResetMixedAudioButton.Visible = "off";
                app.PlotMixedAudioButton.Visible = "off";
                app.audio_samples = [];
            else
                uialert(app.UIFigure, "Enter a valid filename", "FileName Error", Icon="success")
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1089 711];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Scrollable = 'on';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Channel 1')
            xlabel(app.UIAxes, 'Samples')
            ylabel(app.UIAxes, 'Amplitide')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Toolbar.Visible = 'off';
            app.UIAxes.XColor = [0 0 0];
            app.UIAxes.YColor = [0 0 0];
            app.UIAxes.Visible = 'off';
            app.UIAxes.Position = [15 489 808 151];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Channel 2')
            xlabel(app.UIAxes2, 'Samples')
            ylabel(app.UIAxes2, 'Amplitude')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Toolbar.Visible = 'off';
            app.UIAxes2.Visible = 'off';
            app.UIAxes2.Position = [15 315 808 157];

            % Create ImportButton
            app.ImportButton = uibutton(app.UIFigure, 'push');
            app.ImportButton.ButtonPushedFcn = createCallbackFcn(app, @ImportButtonPushed, true);
            app.ImportButton.Position = [15 671 60 23];
            app.ImportButton.Text = 'Import';

            % Create AudioSelectorDropDownLabel
            app.AudioSelectorDropDownLabel = uilabel(app.UIFigure);
            app.AudioSelectorDropDownLabel.HorizontalAlignment = 'right';
            app.AudioSelectorDropDownLabel.Position = [85 671 83 22];
            app.AudioSelectorDropDownLabel.Text = 'Audio Selector';

            % Create AudioSelectorDropDown
            app.AudioSelectorDropDown = uidropdown(app.UIFigure);
            app.AudioSelectorDropDown.Items = {''};
            app.AudioSelectorDropDown.ValueChangedFcn = createCallbackFcn(app, @AudioSelectorDropDownValueChanged, true);
            app.AudioSelectorDropDown.Enable = 'off';
            app.AudioSelectorDropDown.Position = [183 670 640 24];
            app.AudioSelectorDropDown.Value = '';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [847 670 100 23];
            app.PlayButton.Text = 'Play';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [963 670 100 23];
            app.StopButton.Text = 'Stop';

            % Create Slider_3
            app.Slider_3 = uislider(app.UIFigure);
            app.Slider_3.ValueChangingFcn = createCallbackFcn(app, @Slider_3ValueChanging, true);
            app.Slider_3.FontAngle = 'italic';
            app.Slider_3.Visible = 'off';
            app.Slider_3.Position = [61 289 760 3];

            % Create Slider_4
            app.Slider_4 = uislider(app.UIFigure);
            app.Slider_4.ValueChangingFcn = createCallbackFcn(app, @Slider_4ValueChanging, true);
            app.Slider_4.Visible = 'off';
            app.Slider_4.Position = [61 243 760 3];

            % Create SampleStartEditFieldLabel
            app.SampleStartEditFieldLabel = uilabel(app.UIFigure);
            app.SampleStartEditFieldLabel.HorizontalAlignment = 'right';
            app.SampleStartEditFieldLabel.Position = [851 262 74 22];
            app.SampleStartEditFieldLabel.Text = 'Sample Start';

            % Create SampleStartEditField
            app.SampleStartEditField = uieditfield(app.UIFigure, 'numeric');
            app.SampleStartEditField.RoundFractionalValues = 'on';
            app.SampleStartEditField.Editable = 'off';
            app.SampleStartEditField.Visible = 'off';
            app.SampleStartEditField.Position = [940 256 75 34];

            % Create SampleEndEditFieldLabel
            app.SampleEndEditFieldLabel = uilabel(app.UIFigure);
            app.SampleEndEditFieldLabel.HorizontalAlignment = 'right';
            app.SampleEndEditFieldLabel.Position = [851 218 70 22];
            app.SampleEndEditFieldLabel.Text = 'Sample End';

            % Create SampleEndEditField
            app.SampleEndEditField = uieditfield(app.UIFigure, 'numeric');
            app.SampleEndEditField.RoundFractionalValues = 'on';
            app.SampleEndEditField.Editable = 'off';
            app.SampleEndEditField.Visible = 'off';
            app.SampleEndEditField.Position = [936 212 79 34];

            % Create PlaySampleButton
            app.PlaySampleButton = uibutton(app.UIFigure, 'push');
            app.PlaySampleButton.ButtonPushedFcn = createCallbackFcn(app, @PlaySampleButtonPushed, true);
            app.PlaySampleButton.Visible = 'off';
            app.PlaySampleButton.Position = [852 156 87 29];
            app.PlaySampleButton.Text = 'Play Sample';

            % Create StopSampleButton
            app.StopSampleButton = uibutton(app.UIFigure, 'push');
            app.StopSampleButton.ButtonPushedFcn = createCallbackFcn(app, @StopSampleButtonPushed, true);
            app.StopSampleButton.Visible = 'off';
            app.StopSampleButton.Position = [946 156 87 29];
            app.StopSampleButton.Text = 'Stop Sample';

            % Create AddSampleButton
            app.AddSampleButton = uibutton(app.UIFigure, 'push');
            app.AddSampleButton.ButtonPushedFcn = createCallbackFcn(app, @AddSampleButtonPushed, true);
            app.AddSampleButton.Visible = 'off';
            app.AddSampleButton.Position = [854 116 179 29];
            app.AddSampleButton.Text = 'Add Sample';

            % Create PlayMixedAudioButton
            app.PlayMixedAudioButton = uibutton(app.UIFigure, 'push');
            app.PlayMixedAudioButton.ButtonPushedFcn = createCallbackFcn(app, @PlayMixedAudioButtonPushed, true);
            app.PlayMixedAudioButton.Visible = 'off';
            app.PlayMixedAudioButton.Position = [61 156 179 29];
            app.PlayMixedAudioButton.Text = 'Play Mixed Audio';

            % Create ResetMixedAudioButton
            app.ResetMixedAudioButton = uibutton(app.UIFigure, 'push');
            app.ResetMixedAudioButton.ButtonPushedFcn = createCallbackFcn(app, @ResetMixedAudioButtonPushed, true);
            app.ResetMixedAudioButton.Visible = 'off';
            app.ResetMixedAudioButton.Position = [259 156 179 29];
            app.ResetMixedAudioButton.Text = 'Reset Mixed Audio';

            % Create PlotMixedAudioButton
            app.PlotMixedAudioButton = uibutton(app.UIFigure, 'push');
            app.PlotMixedAudioButton.ButtonPushedFcn = createCallbackFcn(app, @PlotMixedAudioButtonPushed, true);
            app.PlotMixedAudioButton.Visible = 'off';
            app.PlotMixedAudioButton.Position = [61 116 179 29];
            app.PlotMixedAudioButton.Text = 'Plot Mixed Audio';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.Visible = 'off';
            app.EditField.Position = [459 110 267 35];

            % Create ExportButton
            app.ExportButton = uibutton(app.UIFigure, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Visible = 'off';
            app.ExportButton.Position = [623 66 103 29];
            app.ExportButton.Text = 'Export';

            % Create ExportMixedAudioButton
            app.ExportMixedAudioButton = uibutton(app.UIFigure, 'state');
            app.ExportMixedAudioButton.ValueChangedFcn = createCallbackFcn(app, @ExportMixedAudioButtonValueChanged, true);
            app.ExportMixedAudioButton.Visible = 'off';
            app.ExportMixedAudioButton.Text = 'Export Mixed Audio';
            app.ExportMixedAudioButton.Position = [259 116 179 29];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Audio_Mixer

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
