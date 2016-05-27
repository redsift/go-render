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