# go-render

[![CircleCI](https://circleci.com/gh/redsift/go-render.svg?style=svg)](https://circleci.com/gh/redsift/go-render) 

[![Docker Repository on Quay](https://quay.io/repository/redsift/go-render/status "Docker Repository on Quay")](https://quay.io/repository/redsift/go-render)

[![Go Report Card](https://goreportcard.com/badge/github.com/redsift/go-render)](https://goreportcard.com/report/github.com/redsift/go-render)


Simple WebKit2 based headless HTML/SVG rasterizer. 

# Docker

Building and running a headless Webkit is typically not trivial. You need a pretty extensive build and runtime environment along with services like a virtual frame buffer. In addition to wrapping this functionality as a go library, this repository includes a sane command line binary that gives you access to a few simple commands. This binary is packages as a public Docker container and gives you access to headless rendering on the Docker compatible platform of your choice.

## Metadata

Get basic page and timing information.

    $ docker run quay.io/redsift/go-render metadata www.google.com
    {
        "Title": "Google",
        "URI": "https://www.google.co.uk/?gfe_rd=cr\u0026ei=EGxRV9_DMdTG8AefmYeoCw\u0026gws_rd=ssl",
        "Timing": {
            "Start": 0.0008351950000000001,
            "Load": 0.346783985,
            "Finish": 0.34761918
        }
    }

## Screenshot

Get a PNG of the page.

    $ docker run quay.io/redsift/go-render snapshot www.yahoo.com -f png > yahoo.png

## Javascript

Execute some javascript in the context of a loaded page. e.g. Page DOM validation tests.

	$ docker run quay.io/redsift/go-render javascript --js window.location.hostname www.bbc.co.uk

You may also supply a `.js` file to execute as the parameter.

## Additional Examples

### Metadata

	# Local filesystem rendering
	$ ... metadata file:///opt/gopath/src/github.com/redsift/go-render/test/local.html

#### Format

`--format` allows extraction of selected fields from the JSON file. e.g. `--format="{{.Title}}"` to just grab the title
or `-f "{{json .Timing}}"` to get the timing information.

### Javascript

	$ ... javascript -j "\"js=\" + window.location.hostname"  www.google.com

#### Local .js file

    $ cat ./test.js
    function t() {
        return { Hostname: window.location.hostname, Pathname: window.location.pathname };
    }
    t();
    
    # Execute a local file, exceptions will set a non-zero exit code
	$ docker run -v test.js:/tmp/host quay.io/redsift/go-render \ 
	  	javascript --js /tmp/host/test.js www.google.com
    
	# Extract a field from the JSON object
	$ ... javascript -j ./test.js -f {{.Hostname}} www.google.com

### Snapshot

	# Capture a png to stdout
	$ ... snapshot www.google.com

	# Capture a webp as a file
	$ ... snapshot -o google.webp www.google.com

	# Capture multiple URLS and construct filenames from the hostname
	$ render snapshot -o grab-{{.Host}}.png www.google.com www.yahoo.com

## Using Stdin

In addition to passing the URLs on the command line, you may omit the argument and `go-render` will read from the command line. 

	# From stdin where `urls.txt` is a simple list of URLs separated by a newline.
	$ cat urls.txt | ... snapshot -o list-{{.Index}}.png

# How does it work?

This library uses a version of [go-webkit2](https://github.com/sourcegraph/go-webkit2). The docker image bundles the [Xvfb](https://en.wikipedia.org/wiki/Xvfb) virtual frame-buffer. The runtime image is stripped down using syscall tracing to reduce the size requirements for the binary by an order of magnitude.


# Developers

## Xvfb

`xdpyinfo` can provide stats on the virtual frame buffer.
        
        
## Tracing
        
        sudo apt-get install strace
        
        sudo strace -f -o $CIRCLE_ARTIFACTS/bash.strace.out -p 49350
        
# Know issues

- Due to timing issues with the cleanup of the process tree, WebKit might occasionally emit errors as it shuts down. e.g. `(WebKitWebProcess:26): Gdk-WARNING **: WebKitWebProcess: Fatal IO error 11 (Resource temporarily unavailable) on X server :1.`        
- Some URLs may not successfully snapshot. e.g. `docker run quay.io/redsift/go-render snapshot www.shazam.com` -> `render: error: Unable to create snapshot: There was an error creating the snapshot`. This is usually due to a 0x0 pixel display at the time of invoking the snapshot.
