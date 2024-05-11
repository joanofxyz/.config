#r "C:\\Program Files\\workspacer\\workspacer.Shared.dll"
#r "C:\\Program Files\\workspacer\\plugins\\workspacer.Bar\\workspacer.Bar.dll"

using System;
using System.Diagnostics;
using workspacer;
using workspacer.Bar;
using workspacer.Bar.Widgets;


var themes = new {
	Gruvbox = new {
		Foreground = new Color(0xeb, 0xdb, 0xb2),
		Background = new Color(0x28, 0x28, 0x28),
		WorkspaceHasFocusColor = new Color(0xfa, 0xbd, 0x2f),
		WorkspaceEmptyColor = new Color(0xa8, 0x99, 0x84),
		WorkspaceIndicatingBackColor = new Color(0x68, 0x9d, 0x6a),
	},
	Oxocabron = new {
		Foreground = new Color(0xab, 0xab, 0xab),
		Background = new Color(0x26, 0x26, 0x26),
		WorkspaceHasFocusColor = new Color(0x58, 0x66, 0x52),
		WorkspaceEmptyColor = new Color(0x7d, 0x7d, 0x7d),
		WorkspaceIndicatingBackColor = new Color(0x52, 0x66, 0x5f),
	},
	OxocabronBright = new {
		Foreground = new Color(0xb1, 0xb1, 0xb1),
		Background = new Color(0x30, 0x30, 0x30),
		WorkspaceHasFocusColor = new Color(0x63, 0x75, 0x5b),
		WorkspaceEmptyColor = new Color(0x7d, 0x7d, 0x7d),
		WorkspaceIndicatingBackColor = new Color(0x5b, 0x75, 0x6c),
	}
};


return new Action<IConfigContext>((IConfigContext context) => {
		var theme = themes.OxocabronBright;
		context.Branch = Branch.Unstable;
		context.CanMinimizeWindows = true;
    context.AddBar(new BarPluginConfig(){
			FontSize = 12,
			FontName = "UbuntuMono NF",
			BarHeight = 26,
			DefaultWidgetForeground = theme.Foreground,
			DefaultWidgetBackground = theme.Background,
			Background = theme.Background,
			LeftWidgets = () => new IBarWidget[]{
				new TextWidget(" "),
				new WorkspaceWidget(){
					WorkspaceHasFocusColor = theme.WorkspaceHasFocusColor,
					WorkspaceEmptyColor = theme.WorkspaceEmptyColor,
					WorkspaceIndicatingBackColor = theme.WorkspaceIndicatingBackColor,
				},
				new TextWidget(" "),
				new TitleWidget(){
					IsShortTitle = true,
					NoWindowMessage = "",
				},
			},
			RightWidgets = () => new IBarWidget[]{
				new TimeWidget(1000, "HH:mm:ss dd/MM/yyyy"),
			},
		});



		// workspaces
		(string, ILayoutEngine, ILayoutEngine)[] workspaces = {
			("main", new DwindleLayoutEngine(1, 0.4, 0.05), new FullLayoutEngine()),
			("secondary", new DwindleLayoutEngine(), new FullLayoutEngine()),
			("media", new TallLayoutEngine(1, 0.3, 0.05, false), new FullLayoutEngine()),
		};
		foreach ((string name, ILayoutEngine main_layout, ILayoutEngine secondary_layout) in workspaces){
			context.WorkspaceContainer.CreateWorkspace(name, main_layout, secondary_layout);
		}


		// filters
		string[] filters = {
			"pinentry.exe",
			"Wally.exe",
			"msiexec.exe",
			"dllhost.exe",
			"main.exe",
			"msrdc.exe",
			"wsl.exe",
			"wslhost.exe",
			"wslrelay.exe",
			"wslservice.exe",
		};
		foreach (string name in filters){
			context.WindowRouter.AddFilter((window) => !window.ProcessFileName.Equals(name));
		}


		// routes
		context.WindowRouter.RouteProcessName("Spotify", "media");
		context.WindowRouter.RouteTitle("Netflix", "media");
		context.WindowRouter.RouteProcessName("stremio.exe", "media");


		// keybindings
		KeyModifiers altWin = KeyModifiers.Win | KeyModifiers.Alt;
		KeyModifiers altShift = KeyModifiers.Alt | KeyModifiers.Shift;
		KeyModifiers altWinShift = KeyModifiers.Win | KeyModifiers.Alt | KeyModifiers.Shift;

		IKeybindManager keys = context.Keybinds;

		keys.UnsubscribeAll();

		keys.Subscribe(altWinShift, Keys.A    , () => Process.Start("alacritty", "wsl ~"));

		keys.Subscribe(altShift   , Keys.J    , () => context.Workspaces.FocusedWorkspace.FocusPreviousWindow()         , "focus previous window");
		keys.Subscribe(altShift   , Keys.K    , () => context.Workspaces.FocusedWorkspace.FocusNextWindow()             , "focus next window");
		keys.Subscribe(altShift   , Keys.H    , () => context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow()  , "swap focus and previous window");
		keys.Subscribe(altShift   , Keys.L    , () => context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow()      , "swap focus and next window");

		keys.Subscribe(altWin     , Keys.Left , () => context.Workspaces.SwitchToPreviousWorkspace()                    , "switch to previous workspace");
		keys.Subscribe(altWin     , Keys.Right, () => context.Workspaces.SwitchToNextWorkspace()                        , "switch to next workspace");
		keys.Subscribe(altWinShift, Keys.Left , () => context.Workspaces.MoveFocusedWindowAndSwitchToPreviousWorkspace(), "move window to previous workspace");
		keys.Subscribe(altWinShift, Keys.Right, () => context.Workspaces.MoveFocusedWindowAndSwitchToNextWorkspace()    , "move window to next workspace");

		keys.Subscribe(altWinShift, Keys.Q    , () => context.Restart()                                                 , "restart workspacer");
		keys.Subscribe(altWin     , Keys.Q    , () => context.Workspaces.FocusedWorkspace.ResetLayout()                 , "reset layout");
		keys.Subscribe(altWin     , Keys.N    , () => context.Workspaces.FocusedWorkspace.NextLayoutEngine()            , "next layout");
		keys.Subscribe(altShift   , Keys.Enter, () => context.Workspaces.FocusedWorkspace.SwapFocusAndPrimaryWindow()   , "swap focus and primary window");
		keys.Subscribe(altWinShift, Keys.H    , () => context.Workspaces.FocusedWorkspace.ShrinkPrimaryArea()           , "shrink primary area");
		keys.Subscribe(altWinShift, Keys.L    , () => context.Workspaces.FocusedWorkspace.ExpandPrimaryArea()           , "expand primary area");
});
