'''VoidFinder - Hoyle & Vogeley (2002)'''

################################################################################
#
#   IMPORT MODULES
#
################################################################################

from voidfinder import filter_galaxies, find_voids

from astropy.io import fits
from astropy.table import Table

from absmag_comovingdist_functions import Distance

import pickle

################################################################################
#
#   USER INPUTS
#
################################################################################


survey_name = 'DESI_dc17_'

# File header
in_directory = '/scratch/kdougla7/VoidFinder/DESI/'
out_directory = '/scratch/kdougla7/VoidFinder/DESI/'

# Input file names
in_filename = in_directory + 'DESI_sgc.fits' # File format: RA, dec, redshift, comoving distance, absolute magnitude
mask_filename = in_directory + 'dc17sgcmask.dat' # File format: RA, dec

# Output file names
out1_filename = out_directory + in_filename[:-5] + '_maximal.txt' # List of maximal spheres of each void region: x, y, z, radius, distance, ra, dec
out2_filename = out_directory + in_filename[:-5] + '_holes.txt' # List of holes for all void regions: x, y, z, radius, flag (to which void it belongs)
'''out3_filename = 'out3_vollim_dr7.txt' # List of void region sizes: radius, effective radius, evolume, x, y, z, deltap, nfield, vol_maxhole
voidgals_filename = 'vollim_voidgals_dr7.txt' # List of the void galaxies: x, y, z, void region '''

#ngrid = 128     # Number of grid cells
max_dist = 3400. # z_ngc = 1.5--> 4158 h-1 Mpc # z_sgc = 1.1 --> 3374
#box = 630.      # Size of survey/simulation box
dl = 5.         # Cell side length [Mpc/h]


################################################################################
#
#   OPEN FILES
#
################################################################################

'''
infile = Table.read(in_filename, format='ascii.commented_header')
maskfile = Table.read(mask_filename, format='ascii.commented_header')
'''
gal_file = fits.open(in_filename) 
infile = Table(gal_file[1].data)
maskfile = Table.read(mask_filename, format='ascii.commented_header')

survey_name = 'DC17_SGC_'

################################################################################
#
#   FILTER GALAXIES
#
################################################################################


#coord_min_table, mask = filter_galaxies(in_filename, mask_filename, ngrid, box, max_dist)
coord_min_table, mask, ngrid = filter_galaxies(infile, maskfile, dl, max_dist, survey_name)


################################################################################
#
#   FIND VOIDS
#
################################################################################


find_voids(ngrid, dl, max_dist, coord_min_table, mask, out1_filename, out2_filename, survey_name)
