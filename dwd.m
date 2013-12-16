#include <Cocoa/Cocoa.h>

#include <err.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>

void
usage(void)
{
	fprintf(stderr, "usage: %s [options ...] duration\n"
	    "\t-c color as rgb in hex (default 7f7f7f)\n"
	    "\t-a alpha as float (default 0.75)\n"
	    "\t-d don't hide the dock (default hidden)\n"
	    "\tduration is specified in seconds\n",
	    getprogname());
	exit(EX_USAGE);
}

int
main(int argc, char *argv[])
{
	unsigned char red = 127;
	unsigned char green = 127;
	unsigned char blue = 127;
	long temp_color;
	float alpha = 0.75;
	bool coverDock = true;
	float duration;
	int c;

	while ((c = getopt(argc, argv, "c:a:dh")) != -1) {
		switch (c) {
		case 'c':
			// validation could be tighter
			if (strlen(optarg) != 6)
				errx(EX_USAGE, "invalid color");
			temp_color = strtol(optarg, NULL, 16);
			if (temp_color < 0)
				errx(EX_USAGE, "invalid color");
			red =   (temp_color & 0xff0000) >> 16;
			green = (temp_color & 0x00ff00) >> 8;
			blue =   temp_color & 0x0000ff;
			break;
		case 'a':
			alpha = strtof(optarg, NULL);
			if (alpha < 0.0 || alpha > 1.0)
				errx(EX_USAGE, "alpha must be between 0 and 1");
			break;
		case 'd':
			coverDock = false;
			break;
		case 'h': // help
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;

	if (argc != 1)
		usage();

	duration = strtof(argv[0], NULL);
	if (duration <= 0.0)
		errx(EX_USAGE, "duration must be greater than 0");

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSRect frame;
	if (coverDock)
		frame = [[NSScreen mainScreen] frame];
	else
		frame = [[NSScreen mainScreen] visibleFrame];

	NSColor *color = [NSColor colorWithCalibratedRed:(CGFloat)red
	                                           green:(CGFloat)green
	                                            blue:(CGFloat)blue
	                                           alpha:(CGFloat)1.0];

	[NSApplication sharedApplication];

	NSWindow *window = [NSWindow alloc];
	[window initWithContentRect:frame
	                  styleMask:NSBorderlessWindowMask
	                    backing:NSBackingStoreBuffered
	                      defer:NO];
	[window autorelease];
	[window setBackgroundColor: color];
	[window setAlphaValue: alpha];
	[window setIgnoresMouseEvents:TRUE];
	[window makeKeyAndOrderFront:NSApp];
	[window setLevel:NSScreenSaverWindowLevel];

	usleep(duration * 1e6);

	[pool drain];

	return EX_OK;
}
