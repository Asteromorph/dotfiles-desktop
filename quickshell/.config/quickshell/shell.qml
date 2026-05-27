import Quickshell
import "bar" as Bar
import "app-launcher" as Launcher
import "notifications" as Notif
import "theme-switcher" as TS
import "wallpaper" as WP
import "control-center" as CC

ShellRoot {
	TS.ThemeSwitcher { id: ts }
	Bar.Bar { theme: ts.theme }
	Launcher.AppLauncher { theme: ts.theme}
	Notif.NotificationPopup { theme: ts.theme}
	WP.WallpaperManager {}
	CC.ControlCenter { 
		id: controlCenter
		theme: ts.theme
       	}
}

