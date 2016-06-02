# go-render

[![CircleCI](https://circleci.com/gh/Redsift/go-render.svg?style=svg)](https://circleci.com/gh/Redsift/go-render) [![Docker Repository on Quay](https://quay.io/repository/redsift/go-render/status "Docker Repository on Quay")](https://quay.io/repository/redsift/go-render)

Simple webkit2 based rasterizer. 

# Xvfb

`xdpyinfo` can provide stats on the virtual frame buffer.


# Metadata

render metadata www.google.com
render metadata file:///opt/gopath/src/github.com/redsift/go-render/test/local.html

## Format

--format="{{.Title}}" to just grab the title
-f "{{json .Timing}}" to get the timing information

    - |
        TEST=$(docker run $CONTAINER_NAME metadata -f "{{.Title}}" http://www.google.com)
        echo $TEST
        [ "$TEST" == "Google" ]

# Javascript

render javascript -j window.location.hostname  www.google.com
render javascript -j "\"js=\" + window.location.hostname"  www.google.com

## Local .js file

    # ./host.js
    function t() {
        return { Hostname: window.location.hostname, Pathname: window.location.pathname };
    }
    t();
    
render javascript -j ./host.js www.google.com
render javascript -j ./host.js -f {{.Hostname}} www.google.com

# Snapshot

render snapshot -o google.png www.google.com

render snapshot -o grab-{{.Host}}.png www.google.com www.yahoo.com

From stdin where `urls.txt` is a simple list of URLs separated by a newline

cat urls.txt | render snapshot -o list-{{.Index}}.png
        
        
## Tracing
        
        sudo apt-get install strace
        
        sudo strace -f -o $CIRCLE_ARTIFACTS/bash.strace.out -p 49350 
        
        ./filter-trace.py bash.strace.out > needed-files.out
        
        sudo strace -e trace=open,stat,execve -s 80 -f -p 47324
        
