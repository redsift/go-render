#!/usr/bin/env python

from __future__ import print_function

import re
import sets
import sys
import os

def extract_path(pattern, line):
	match = pattern.search(line)
	path = None
	if match:
		operation = match.group(1)
		file = match.group(2)
		status = match.group(3)

		if status is not None:
			if "ENOENT" in status:
				print(operation + " - " + file  + " - " + status, file=sys.stderr)
				return None

		if file is not None:
			path = file

	return path

def flatten(st, path):
	st.add(path)
	if os.path.islink(path):
		print("Warning, " + path  + " is a symlink", file=sys.stderr)
		flatten(st, os.path.realpath(path))

def main():

	if len(sys.argv) < 2:
		print("usage: filter-trace.py <strace output...>")
		exit(1)

	strace_pattern = re.compile('(open|stat|execve)\("([^"]+)".*=\s-?\d\s?(.*)')

	for arg_file in sys.argv[1:]:

		output_file = open(arg_file, "r")

		path_set = sets.Set()

		for line in output_file:

			path = extract_path(strace_pattern, line)
			if path is not None:
				flatten(path_set, path)



		for path in sorted(path_set):
			print(path + " \\")


if __name__ == "__main__":
	main()