#!/usr/bin/env python3

import argparse
import subprocess as sp

from diffsuggest import process_file


def run_trailing_whitespace(linter_path, filename):
    linter_output_filename = '{}.linted'.format(filename)
    with open(linter_output_filename, 'w') as f:
        retcode = sp.Popen([linter_path, filename], stdout=f).wait()
        if retcode != 0:
            exit(retcode)
    return linter_output_filename


parser = argparse.ArgumentParser()
parser.add_argument('linter_path')
parser.add_argument('file')
parser.add_argument('--debug', action='store_true')
parser.add_argument('--delimiter', default=':')
args = parser.parse_args()
for l in process_file(args.file,
                      lambda f: run_trailing_whitespace(args.linter_path, f),
                      delimiter=args.delimiter,
                      debug=args.debug):
    print(l)
