import sys
import argparse
import re

assert sys.version_info.major >= 3, "Python 3 is required for string operations" 

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="Input sequence - fasta file format", required=True)
parser.add_argument("-o", "--output", help="Output file name", default='gc_content.txt')
parser.add_argument("-t", "--threshold", help="Threshold", default=0.0)
parser.add_argument("--stepsize", help="Threshold (regions with gc lower than threshold are discarded)", default=10000)
parser.add_argument("-v", "--verbose", action = 'store_true', help="Add verbosity")
args = parser.parse_args()

threshold = float(args.threshold)
stepsize = int(args.stepsize)

output_data = ['\t'.join(['chromosome', 'start', 'end', 'gc_content'])]

if args.verbose: print('Load data')
with open(args.input, "r") as f:
    data = f.read().splitlines()

if args.verbose: print('Calculate chromosome stats')
chr_names, chr_borders = [], []

for i in range(len(data)):
    if '>' in data[i]:
        chr_names.append(data[i].split('>')[1].split(' ')[0])
        chr_borders.append(i)
chr_borders = chr_borders + [len(data)]

for i in range(len(chr_names)):

    if not re.match("^(chr)?[0-9,X,Y]{1,2}$", chr_names[i]):
        continue

    if args.verbose: print('Calculating Chromosome {} - length = {} aa'.format(chr_names[i], 61*(chr_borders[i+1] - chr_borders[i])))
    current_chr = data[chr_borders[i]:chr_borders[i+1]][1:]
                
    current_chr = ''.join(current_chr)

    for j in range(0, len(current_chr)//stepsize):
        current_data = current_chr[(stepsize*j):(stepsize*(j+1))]

        gc = len(re.findall('[gcGC]', current_data))
        gcta = len(re.findall('[gctaGCTA]', current_data))
        if gcta == 0: gcta = 1.
        gc_content = gc/gcta

        if gc_content > threshold:
            output_data.append('\t'.join([chr_names[i], str(stepsize*j), str(stepsize*(j+1)), '{:1.6f}'.format(gc_content)]))
if args.verbose: print('Finished with calculation. Writing to file {}'.format(args.output))

with open(args.output, 'w') as f:
    for line in output_data:
        f.write("%s\n" % line)
if args.verbose: print('GC-content calculated succesfully')
