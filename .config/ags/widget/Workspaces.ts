import AstalHyprland from "gi://AstalHyprland";
import { Variable, bind } from "astal";
import { type Gtk, Widget } from "astal/gtk3";

export function Workspaces(): Gtk.Widget {
	const hyprland = AstalHyprland.get_default();

	return new Widget.EventBox({
		className: "workspaces-container",
		onScroll: (_, event) =>
			event.delta_y > 0
				? hyprland.dispatch("workspace", "e-1")
				: hyprland.dispatch("workspace", "e+1"),
		child: new Widget.Box({
			className: "workspaces",
			spacing: 4,
			children: bind(hyprland, "workspaces").as((workspaces) =>
				workspaces
					.filter((ws) => ws.id > 0)
					.sort((a, b) => a.id - b.id)
					.map((workspace) => {
						const isActive = Variable.derive(
							[bind(hyprland, "focusedWorkspace")],
							(focusedWs) => focusedWs.id === workspace.id,
						);

						const hasClients = Variable.derive(
							[bind(workspace, "lastClient")],
							(lastClient) => Boolean(lastClient),
						);

						const className = Variable.derive(
							[isActive(), hasClients()],
							(active, clients) =>
								`workspace ${active ? "active" : ""} ${clients ? "occupied" : ""}`,
						);

						return new Widget.EventBox({
							className: className(),
							onClickRelease: () => workspace.focus(),
							tooltipText: `Workspace ${workspace.id}`,
							onDestroy: () => {
								isActive.drop();
								hasClients.drop();
								className.drop();
							},
							child: new Widget.Box({
								className: "workspace-indicator",
								children: [
									new Widget.Label({
										label: workspace.id.toString(),
										className: "workspace-number",
									}),
								],
							}),
						});
					}),
			),
		}),
	});
}
