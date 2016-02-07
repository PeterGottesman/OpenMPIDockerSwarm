#!/usr/bin/env python3

import argparse

def main(args):
    infile = args.infile
    outfile = args.outfile

    with open(infile, 'r') as f:
       inlines = f.readlines() 

    indexes = set([line.split()[0] for line in inlines])
    averages = {}
    for index in indexes:
        values = [float(line.split()[1]) for line in inlines if line.split()[0] == index]
        averages[index] = sum(values)/len(values)

    with open(outfile, 'w') as f:
        for index in sorted(averages, key=int):
            f.write(index + " " + str(averages[index]) + '\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('infile')
    parser.add_argument('outfile')
    
    args = parser.parse_args()
    main(args)

