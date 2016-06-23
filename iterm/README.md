# Docker + iTerm

The excellent iTerm2 supports [displaying images](https://www.iterm2.com/documentation-images.html) in the terminal using a set of proprietary escape sequences.

Based on the standard [imgcat](https://raw.github.com/gnachman/iTerm2/master/tests/imgcat) script, `htmlcat` uses the same sequence to perform a headless render of a HTML file or remote web page in your terminal window. 

![Screenshot from the command line](https://raw.githubusercontent.com/Redsift/go-render/master/iterm/screen.png)

Works best with [Docker for Mac - Beta](https://www.docker.com/products/docker#/mac).

## Limitations

When rendering a local file, the directory of the HTML file is mapped into the container. As a result, paths outside this mapping will not be available such as symlinks or absolute / relative paths are traverse out to parents of this path.