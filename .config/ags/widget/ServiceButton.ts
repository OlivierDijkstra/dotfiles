import { bind } from "astal";
import { Gtk, Widget } from "astal/gtk3";

export interface ServiceButtonProps {
	icon: string;
	title: string;
	statusText?: string;
	enabled?: boolean;
	onClick?: () => void;
	className?: string;
}

// Helper function to create the button structure
const createServiceButtonChild = (
	icon: string,
	title: string,
	statusText: string,
) => {
	return new Widget.Box({
		orientation: Gtk.Orientation.HORIZONTAL,
		spacing: 20,
		halign: Gtk.Align.FILL,
		children: [
			new Widget.Label({
				label: icon,
				className: "service-icon",
				halign: Gtk.Align.CENTER,
				valign: Gtk.Align.CENTER,
			}),
			new Widget.Box({
				orientation: Gtk.Orientation.VERTICAL,
				spacing: 2,
				halign: Gtk.Align.START,
				valign: Gtk.Align.CENTER,
				hexpand: true,
				children: [
					new Widget.Label({
						label: title,
						className: "service-title",
						halign: Gtk.Align.START,
						valign: Gtk.Align.CENTER,
					}),
					new Widget.Label({
						label: statusText,
						className: "service-status",
						halign: Gtk.Align.START,
						valign: Gtk.Align.CENTER,
					}),
				],
			}),
		],
	});
};

export const ServiceButton = ({
	icon,
	title,
	statusText = "",
	enabled = false,
	onClick,
	className = "",
}: ServiceButtonProps) => {
	return new Widget.Button({
		className: `pill-service-button ${enabled ? "enabled" : "disabled"} ${className}`,
		onClick: onClick,
		child: createServiceButtonChild(icon, title, statusText),
	} as Widget.ButtonProps);
};

// Dynamic version for services with reactive state
export const DynamicServiceButton = (
	icon: string,
	title: string,
	// biome-ignore lint/suspicious/noExplicitAny: <explanation>
	service: any,
	enabledProperty: string,
	getStatusText: (enabled: boolean) => string,
	onClick?: () => void,
	className = "",
) => {
	return new Widget.Button({
		className: bind(service, enabledProperty).as(
			(enabled: boolean) =>
				`pill-service-button ${enabled ? "enabled" : "disabled"} ${className}`,
		),
		onClick: onClick,
		child: new Widget.Box({
			orientation: Gtk.Orientation.HORIZONTAL,
			spacing: 20,
			halign: Gtk.Align.FILL,
			children: [
				new Widget.Label({
					label: icon,
					className: "service-icon",
					halign: Gtk.Align.CENTER,
					valign: Gtk.Align.CENTER,
				}),
				new Widget.Box({
					orientation: Gtk.Orientation.VERTICAL,
					spacing: 2,
					halign: Gtk.Align.START,
					valign: Gtk.Align.CENTER,
					hexpand: true,
					children: [
						new Widget.Label({
							label: title,
							className: "service-title",
							halign: Gtk.Align.START,
							valign: Gtk.Align.CENTER,
						}),
						new Widget.Label({
							label: bind(service, enabledProperty).as(getStatusText),
							className: "service-status",
							halign: Gtk.Align.START,
							valign: Gtk.Align.CENTER,
						}),
					],
				}),
			],
		}),
	} as Widget.ButtonProps);
};
