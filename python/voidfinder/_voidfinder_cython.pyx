



cimport cython
import numpy as np
cimport numpy as np
np.import_array()  # required in order to use C-API


cdef extern from "complex.h" nogil:
    float crealf(float complex)
    double creal(double complex)
    long double creall(long double complex)


ctypedef np.complex128_t DTYPE_CP128_t
ctypedef np.complex64_t DTYPE_CP64_t
ctypedef np.float64_t DTYPE_F64_t  
ctypedef np.float32_t DTYPE_F32_t
ctypedef np.uint8_t DTYPE_B_t
ctypedef np.intp_t ITYPE_t  
ctypedef np.int32_t DTYPE_INT32_t

from numpy.math cimport NAN, INFINITY


from libc.math cimport fabs, sqrt, asin, atan#, exp, pow, cos, sin, asin




@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cpdef void main_algorithm(int i, 
                          int j, 
                          int k,
                          galaxy_tree,
                          DTYPE_F64_t[:,:] w_coord,
                          DTYPE_F64_t dl, 
                          DTYPE_F64_t dr,
                          DTYPE_F64_t[:,:] coord_min, 
                          DTYPE_B_t[:,:,:] mask,
                          DTYPE_F64_t min_dist,
                          DTYPE_F64_t max_dist,
                          DTYPE_F64_t[:] return_array
                          ) except *:
    '''
    hole_center variables need to be shape (1,3) for KDTree queries
    everything else can be shape (3,)
    '''
    
   
    #i, j, k = hole_center_coords
    
    
    '''
    print(i,j,k)
    print(galaxy_tree)
    print(w_coord)
    print(dl)
    print(dr)
    print(coord_min)
    print(mask)
    print(min_dist)
    print(max_dist)
    print(return_array)
    '''
    
    
    #print(mask)
    #print(type(mask))
    #print(mask.dtype)
    #print(mask.shape)
    
    
    
    cdef DTYPE_B_t galaxy_search
    cdef DTYPE_B_t in_mask_2
    cdef DTYPE_B_t in_mask_3
    cdef DTYPE_B_t in_mask_41
    cdef DTYPE_B_t in_mask_42
    
    cdef DTYPE_F64_t[:,:] hole_center_memview = np.empty((1,3), dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:,:] hole_center_2_memview = np.empty((1,3), dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:,:] hole_center_3_memview = np.empty((1,3), dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:,:] hole_center_41_memview = np.empty((1,3), dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:,:] hole_center_42_memview = np.empty((1,3), dtype=np.float64, order='C')
    
    #cdef DTYPE_F64_t[:] neighbor_1_w_coords_memview = np.empty(3, dtype=np.float64, order='C')
    
    cdef DTYPE_F64_t[:] v3_memview = np.empty(3, dtype=np.float64, order='C')
    
    cdef DTYPE_F64_t[:] v1_unit_memview = np.empty(3, dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:] v2_unit_memview = np.empty(3, dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:] v3_unit_memview = np.empty(3, dtype=np.float64, order='C')
    
    cdef DTYPE_F64_t modv1
    cdef DTYPE_F64_t modv2
    cdef DTYPE_F64_t modv3
    
    cdef ITYPE_t k1g
    cdef ITYPE_t k2g
    cdef ITYPE_t k3g
    cdef ITYPE_t k4g1
    cdef ITYPE_t k4g2
    cdef ITYPE_t k4g
    
    cdef ITYPE_t k2g_x2
    cdef ITYPE_t k3g_x3
    cdef ITYPE_t k4g1_x41
    cdef ITYPE_t k4g2_x42

    cdef DTYPE_F64_t minx3
    cdef DTYPE_F64_t minx41
    cdef DTYPE_F64_t minx42
    
    
    
    
    
    
    
    cdef ITYPE_t[:] i_nearest_memview

    cdef ITYPE_t num_nearest

    cdef DTYPE_F64_t[:,:] BA_memview

    cdef DTYPE_F64_t[:] bot_memview
    cdef DTYPE_F64_t[:] top_memview

    cdef DTYPE_F64_t[:] x2_memview
    cdef DTYPE_F64_t[:] x3_memview
    cdef DTYPE_F64_t[:] x41_memview
    cdef DTYPE_F64_t[:] x42_memview

    #cdef DTYPE_B_t[:] valid_idx_memview

    cdef DTYPE_B_t any_valid

    cdef ITYPE_t valid_min_idx

    cdef DTYPE_F64_t valid_min_val
    
    
    
    
    cdef DTYPE_F64_t temp_f64_accum
    cdef DTYPE_F64_t temp_f64_accum2
    cdef DTYPE_F64_t temp_f64_val
    
    
    
    
    cdef DTYPE_F64_t hole_radius
    
    
    cdef DTYPE_F64_t[:] midpoint_memview = np.empty(3, dtype=np.float64, order='C')
    
    cdef DTYPE_F64_t[:] Acenter_memview = np.empty(3, dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:] Bcenter_memview = np.empty(3, dtype=np.float64, order='C')
    
    cdef DTYPE_F64_t[:,:] Ccenter_memview
    cdef DTYPE_F64_t[:,:] Dcenter_memview
    
    cdef DTYPE_F64_t[:,:] C_minus_A_center_memview
    cdef DTYPE_F64_t[:,:] D_minus_A_center_memview

    cdef DTYPE_F64_t[:] AB_memview = np.empty(3, dtype=np.float64, order='C')
    cdef DTYPE_F64_t[:] BC_memview = np.empty(3, dtype=np.float64, order='C')
    
    
    cdef DTYPE_F64_t search_radius
    
    
    '''
    hole_center = (np.array([[i, j, k]], dtype=np.float64) + 0.5)*dl + coord_min  # Purposefully making hole_center have shape (1,3) for KDtree queries
    '''
    hole_center_memview[0,0] = i
    hole_center_memview[0,1] = j
    hole_center_memview[0,2] = k
    
    
    cdef ITYPE_t idx
    cdef ITYPE_t jdx
    cdef ITYPE_t temp_idx
    
    for idx in range(3):
        
        hole_center_memview[0,idx] = (hole_center_memview[0,idx] + 0.5)*dl + coord_min[0,idx]
        
    
    
    
    #np.add(hole_center_memview, 0.5, out=hole_center_memview)
    #np.multiply(hole_center_memview, dl, out=hole_center_memview)
    #np.add(hole_center_memview, coord_min, out=hole_center_memview)
    
    
    #hole_center_memview = hole_center
                    
    '''
    print("Hole center")
    print(hole_center)
    print(type(hole_center))
    print(hole_center.dtype)
    '''
    #exit()
    
                    
    # Check to make sure that the hole center is still within the survey
    if not_in_mask(hole_center_memview, mask, min_dist, max_dist):
        
        
        return_array[0] = NAN
        return_array[1] = NAN
        return_array[2] = NAN
        return_array[3] = NAN
        
        return 
    
    
    ############################################################
    #
    # Find Galaxy 1 (closest to cell center)
    #
    # and calculate Unit vector pointing from cell 
    # center to the closest galaxy
    #
    # After [0][0] indexing, modv1 is a float scalar and
    # k1g is an integer scalar
    # The first [0] index gives us the 'array' corresponding to
    # query sample 0, and the second [0] index gives us the value
    # of the neighbor for that query sample, and since we set k=1
    # we don't have to worry about sorting the results
    #
    #
    ############################################################
    neighbor_1_dists, neighbor_1_idxs = galaxy_tree.query(hole_center_memview, k=1)
    
    #print(modv1.shape)
    #print(k1g.shape)
    
    
    
    #modulus of vector 1, dist from galaxy 1 to cell center
    modv1 = neighbor_1_dists[0][0] #float64
    #neighbor_1_dist = modv1
    
    
    #neighbor 1 galaxy index
    k1g = neighbor_1_idxs[0][0] #integer index
    #neighbor_1_idx = k1g
    
    '''
    #galaxy 1 unit vector
    v1_unit = (w_coord[k1g] - hole_center)/modv1 #np.ndarray shape (1,3)
    '''
    
    for idx in range(3):
        
        # Removed memview
        #neighbor_1_w_coords_memview[idx] = w_coord[k1g,idx]
        
        v1_unit_memview[idx] = (w_coord[k1g,idx] - hole_center_memview[0,idx])/modv1
    
    
    #print("V1_unit shape: ", type(v1_unit), v1_unit.shape) 
    
    #print(modv1)
    #print(k1g)
    #print(v1_unit)

    ############################################################
    #
    # Find Galaxy 2 
    #
    # We are going to shift the center of the hole by dr along 
    # the direction of the vector pointing from the nearest 
    # galaxy to the center of the empty cell.  From there, we 
    # will search within a radius of length the distance between 
    # the center of the hole and the first galaxy from the 
    # center of the hole to find the next nearest neighbors.  
    # From there, we will minimize top/bottom to find which one 
    # is the next nearest galaxy that bounds the hole.
    ############################################################

    galaxy_search = True
    
    
    ############################################################
    # Update hole center 2
    ############################################################
    '''
    hole_center_2 = hole_center
    '''
    for idx in range(3):
        hole_center_2_memview[0,idx] = hole_center_memview[0,idx]

    in_mask_2 = True

    while galaxy_search:
        '''
        # Shift hole center away from first galaxy
        hole_center_2 = hole_center_2 - dr*v1_unit
        '''
        for idx in range(3):
            
            hole_center_2_memview[0,idx] = hole_center_2_memview[0,idx] - dr*v1_unit_memview[idx]
        
        
        
        # Distance between hole center and nearest galaxy
        modv1 += dr
        
        ############################################################
        # Search for nearest neighbors within modv1 of the hole center
        #
        # given data.shape = (N,M)
        # output = tree.query_radius(data, r=radius)
        # output.shape will be (N,), and len(output[i]) == K where
        # K values are returned for the ith of N samples.
        #
        # Since below, N always == 1, we can just use the 0 index
        # to get the K results for our single query point
        # 
        ############################################################
        i_nearest = galaxy_tree.query_radius(hole_center_2_memview, r=modv1)

        i_nearest = i_nearest[0] 
        
        #i_nearest is now an array of shape (K,) where K represents number
        #of galaxies returned
        
        boolean_nearest = i_nearest != k1g
        
        i_nearest = i_nearest[boolean_nearest]
        
        
        #print(type(w_coord))
        #print(i_nearest.dtype)
        #print(type(k1g))
        
        
        #num_nearest is int of ITYPE_t
        num_nearest = i_nearest.shape[0]

        if num_nearest > 0:
            # Found at least one other nearest neighbor!

            # Calculate vector pointing from next nearest galaxies to the nearest galaxy
            
            #print(w_coord.shape)
            #print(i_nearest)
            
            i_nearest_memview = i_nearest

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            temp1 = w_coord[k1g]
            
            temp2 = np.take(w_coord, i_nearest, axis=0)
            
            #elementwise distances between galaxy B and A
            BA = np.subtract(temp1, temp2)  # shape (N,3)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------

            BA_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                for jdx in range(3):
                    
                    temp_idx = i_nearest_memview[idx]
                    
                    BA_memview[idx,jdx] = w_coord[k1g,jdx] - w_coord[temp_idx, jdx]
            
            #-------------------------------------------------------------------
            ####################################################################
            



            
            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            bot = 2*np.dot(BA, v1_unit.T)  # shape (N,1)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------

            bot_memview = np.empty(num_nearest, dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += BA_memview[idx,jdx]*v1_unit_memview[jdx]
                    
                bot_memview[idx] = temp_f64_accum
                    
            #-------------------------------------------------------------------
            ####################################################################   
            
            
            
            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            top = np.sum(BA**2, axis=1)  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            top_memview = np.empty(num_nearest, dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += BA_memview[idx,jdx]*BA_memview[idx,jdx]
                    
                top_memview[idx] = temp_f64_accum
            
            #-------------------------------------------------------------------
            ####################################################################

            

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            #x2 = temp name
            x2 = top/bot.T[0]  # shape (N,) instead of (1,N)
            '''
            #-------------------------------------------------------------------
            # Cython version
            # 
            # CAN POSSIBLE COMBINE THESE THREE CHUNKS INTO ONE SINGLE FOR-LOOP
            #-------------------------------------------------------------------
            
            x2_memview = np.empty(num_nearest, dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                x2_memview[idx] = top_memview[idx]/bot_memview[idx]
            
            #-------------------------------------------------------------------
            ####################################################################
            
            
            

            # Locate positive values of x2

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            #note np.where returns a list of integer indices of locations where
            #the condition is true, , not a boolean array
            valid_idx = np.where(x2 > 0)[0]  # shape (n,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            any_valid = 0
            
            valid_min_idx = 0
            
            valid_min_val = INFINITY
            
            #valid_idx_memview = np.empty(num_nearest, dtype=np.uint8, order='C')
            
            for idx in range(num_nearest):
                
                temp_f64_val = x2_memview[idx]
                
                if temp_f64_val > 0.0:
                    
                    #valid_idx_memview[idx] = 1
                    
                    any_valid = 1
                    
                    if temp_f64_val < valid_min_val:
                        
                        valid_min_idx = idx
                        
                        valid_min_val = temp_f64_val
                    
            #-------------------------------------------------------------------
            ####################################################################



            ####################################################################
            # Python version
            #
            # CANNOT KEEP DUE TO FLAGS SET IN IF-BLOCK
            #-------------------------------------------------------------------
            
            '''
            if len(valid_idx) > 0:
                # Find index of 2nd nearest galaxy
                k2g_x2 = valid_idx[x2[valid_idx].argmin()]
                
                k2g = i_nearest[k2g_x2]

                #minx2 = x2[k2g_x2]  # Eliminated transpose on x2

                galaxy_search = False
            '''

            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
                
            if any_valid:
            
                #used to index into the BA distance array
                k2g_x2 = valid_min_idx
                
                #used to index into the w_coord array
                k2g = i_nearest_memview[valid_min_idx]
                
                galaxy_search = False
                
            #-------------------------------------------------------------------
            ####################################################################
                

            
        elif not_in_mask(hole_center_2_memview, mask, min_dist, max_dist):
            # Hole is no longer within survey limits
            galaxy_search = False
            
            in_mask_2 = False

    # Check to make sure that the hole center is still within the survey
    if not in_mask_2:
        #print('hole not in survey')
        
        #put_start = time.time()
        
        #return_queue.put(("data", (None, None, None, None)))
        
        #time_returning += time.time() - put_start
        
        #continue
    
        return_array[0] = NAN
        return_array[1] = NAN
        return_array[2] = NAN
        return_array[3] = NAN
        
        return 

    #print('Found 2nd galaxy')




    ############################################################################
    # Update hole center
    ############################################################################


    # Calculate new hole center

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_radius = 0.5*np.sum(BA[k2g_x2]**2)/np.dot(BA[k2g_x2], v1_unit.T)  # shape (1,)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------
    
    temp_f64_accum = 0.0
    
    temp_f64_accum2 = 0.0
    
    for idx in range(3):
        
        temp_f64_val = BA_memview[k2g_x2, idx]
        
        temp_f64_accum += temp_f64_val*temp_f64_val
        
        temp_f64_accum2 += BA_memview[k2g_x2, idx]*v1_unit_memview[idx]
        
    hole_radius = 0.5*temp_f64_accum/temp_f64_accum2
        
    #---------------------------------------------------------------------------
    ############################################################################
    
    
    
    
    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_center = w_coord[k1g] - hole_radius*v1_unit  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------
    
    for idx in range(3):
        
        hole_center_memview[0,idx] = w_coord[k1g,idx] - hole_radius*v1_unit_memview[idx]
    
    #---------------------------------------------------------------------------
    ############################################################################
   
   
   
   
    # Check to make sure that the hole center is still within the survey
    if not_in_mask(hole_center_memview, mask, min_dist, max_dist):
        #print('hole not in survey')
        
        #put_start = time.time()
        
        #return_queue.put(("data", (None, None, None, None)))
        
        #time_returning += time.time() - put_start
        
        #continue
    
        return_array[0] = NAN
        return_array[1] = NAN
        return_array[2] = NAN
        return_array[3] = NAN
        
        return 






    ############################################################################
    # Find Galaxy 3 (closest to cell center)
    #
    # (Same methodology as for finding the second galaxy)
    ############################################################################


    # Find the midpoint between the two nearest galaxies
    
    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    midpoint = 0.5*(np.add(w_coord[k1g], w_coord[k2g]))  # shape (3,)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------    
    
    for idx in range(3):
        
        midpoint_memview[idx] = 0.5*(w_coord[k1g,idx] + w_coord[k2g,idx])
    
    #---------------------------------------------------------------------------
    ############################################################################
    
    
    
    
    # Define the unit vector along which to move the hole center

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    # modulus of v2
    modv2 = np.linalg.norm(hole_center - midpoint)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    temp_f64_accum = 0.0
    
    for idx in range(3):
        
        temp_f64_val = hole_center_memview[0,idx] - midpoint_memview[idx]
        
        temp_f64_accum += temp_f64_val*temp_f64_val
    
    modv2 = sqrt(temp_f64_accum)
    
    #---------------------------------------------------------------------------
    ############################################################################
    
    
    
    
    
    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    v2_unit = (hole_center - midpoint)/modv2  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------
    
    for idx in range(3):
    
        v2_unit_memview[idx] = (hole_center_memview[0,idx] - midpoint_memview[idx])/modv2
    
    #---------------------------------------------------------------------------
    ############################################################################
    
    
    

    # Calculate vector pointing from the hole center to the nearest galaxy
    
    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    Acenter = w_coord[k1g] - hole_center  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------
    
    for idx in range(3):
        
        Acenter_memview[idx] = w_coord[k1g, idx] - hole_center_memview[0,idx]
    
    #---------------------------------------------------------------------------
    ############################################################################
    
    
    
    
    
    # Calculate vector pointing from the hole center to the second-nearest galaxy

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    Bcenter = w_coord[k2g] - hole_center  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------
    
    for idx in range(3):
        
        Bcenter_memview[idx] = w_coord[k2g, idx] - hole_center_memview[0,idx]
    
    #---------------------------------------------------------------------------
    ############################################################################
    
    


    # Initialize moving hole center

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_center_3 = hole_center  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------
    
    for idx in range(3):
        
        hole_center_3_memview[0,idx] = hole_center_memview[0,idx]
    
    #---------------------------------------------------------------------------
    ############################################################################
    
    
    
    
    
    galaxy_search = True

    in_mask_3 = True

    while galaxy_search:




        # Shift hole center along unit vector

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center_3 = hole_center_3 + dr*v2_unit
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------
            
        for idx in range(3):
            
            hole_center_3_memview[0,idx] = hole_center_3_memview[0,idx] + dr*v2_unit_memview[idx]
        
        #-----------------------------------------------------------------------
        ########################################################################
        
        
        
        

        # New hole "radius"

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        search_radius = np.linalg.norm(w_coord[k1g] - hole_center_3)
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------
        
        temp_f64_accum = 0.0
        
        for idx in range(3):
            
            temp_f64_val = w_coord[k1g,idx] - hole_center_3_memview[0,idx]
            
            temp_f64_accum += temp_f64_val*temp_f64_val
            
        search_radius = sqrt(temp_f64_accum)
        
        #-----------------------------------------------------------------------
        ########################################################################
        
        
        
        
        
        # Search for nearest neighbors within modv1 of the hole center
        i_nearest = galaxy_tree.query_radius(hole_center_3_memview, r=search_radius)

        i_nearest = i_nearest[0]

        # Remove two nearest galaxies from list
        boolean_nearest = np.logical_and(i_nearest != k1g, i_nearest != k2g)
        
        i_nearest = i_nearest[boolean_nearest]

        #num_nearest is int of ITYPE_t
        num_nearest = i_nearest.shape[0]

        if num_nearest > 0:
            # Found at least one other nearest neighbor!
            
            i_nearest_memview = i_nearest  # Needed for cython only


            
            # Calculate vector pointing from hole center to next nearest galaxies

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            temp_1 = np.take(w_coord, i_nearest, axis=0)
            
            Ccenter = np.subtract(temp_1, hole_center)  # shape (N,3)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
                
            Ccenter_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                for jdx in range(3):
                    
                    temp_idx = i_nearest_memview[idx]
                    
                    Ccenter_memview[idx,jdx] = w_coord[temp_idx, jdx] - hole_center_memview[0,jdx]
            
            #-------------------------------------------------------------------
            ####################################################################
            
            
            
            
            
            
            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            bot = 2*np.dot((Ccenter - Acenter), v2_unit.T)  # shape (N,1)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE BELOW FOR-LOOPS
            #-------------------------------------------------------------------

            bot_memview = np.empty(num_nearest, dtype=np.float64, order='C')


            C_minus_A_center_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                for jdx in range(3):
                    
                    C_minus_A_center_memview[idx, jdx] = Ccenter_memview[idx, jdx] - Acenter_memview[jdx]

            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += C_minus_A_center_memview[idx,jdx]*v2_unit_memview[jdx]
                    
                bot_memview[idx] = 2*temp_f64_accum
            
            #-------------------------------------------------------------------
            ####################################################################
            
            
            
            
            
            
            
            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            top = np.sum(Ccenter**2, axis=1) - np.sum(Bcenter**2)  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE BELOW FOR-LOOPS
            #-------------------------------------------------------------------
            
            top_memview = np.empty(num_nearest, dtype=np.float64, order='C')
            
            temp_f64_accum = 0.0
            
            for idx in range(3):
                
                temp_f64_accum += Bcenter_memview[idx]*Bcenter_memview[idx]
                
            temp_f64_val = temp_f64_accum
            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += Ccenter_memview[idx,jdx]*Ccenter_memview[idx,jdx]
                    
                top_memview[idx] = temp_f64_accum - temp_f64_val
            
            #-------------------------------------------------------------------
            ####################################################################
            
            
            
            
            
            
            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            x3 = top/bot.T[0]  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE ABOVE FOR-LOOP BLOCKS
            #-------------------------------------------------------------------

            x3_memview = np.empty(num_nearest, dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                x3_memview[idx] = top_memview[idx]/bot_memview[idx]

            #-------------------------------------------------------------------
            ####################################################################




            # Locate positive values of x3

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            valid_idx = np.where(x3 > 0)[0]  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            any_valid = 0
            
            valid_min_idx = 0
            
            valid_min_val = INFINITY
            
            #valid_idx_memview = np.empty(num_nearest, dtype=np.uint8, order='C')
            
            for idx in range(num_nearest):
                
                temp_f64_val = x3_memview[idx]
                
                if temp_f64_val > 0.0:
                    
                    #valid_idx_memview[idx] = 1
                    
                    any_valid = 1
                    
                    if temp_f64_val < valid_min_val:
                        
                        valid_min_idx = idx
                        
                        valid_min_val = temp_f64_val

            #-------------------------------------------------------------------
            ####################################################################






            ####################################################################
            # Python version
            #
            # CANNOT KEEP DUE TO FLAGS SET IN IF-BLOCK
            #-------------------------------------------------------------------
            '''
            if len(valid_idx) > 0:
                # Find index of 3rd nearest galaxy
                k3g_x3 = valid_idx[x3[valid_idx].argmin()]
                k3g = i_nearest[k3g_x3]

                minx3 = x3[k3g_x3]

                galaxy_search = False
            '''

            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            if any_valid:
                
                #used to index into the BA distance array
                k3g_x3 = valid_min_idx
                
                #used to index into the w_coord array
                k3g = i_nearest_memview[valid_min_idx]

                # ???????
                minx3 = x3_memview[k3g_x3]
                
                galaxy_search = False
            
            #-------------------------------------------------------------------
            ####################################################################





        elif not_in_mask(hole_center_3_memview, mask, min_dist, max_dist):
            # Hole is no longer within survey limits
            galaxy_search = False
            in_mask_3 = False



    # Check to make sure that the hole center is still within the survey
    if not in_mask_3:
        #print('hole not in survey')
        
        #put_start = time.time()
        
        #return_queue.put(("data", (None, None, None, None)))
        
        #time_returning += time.time() - put_start
        
        #continue
    
        return_array[0] = NAN
        return_array[1] = NAN
        return_array[2] = NAN
        return_array[3] = NAN
        
        return 

    #print('Found 3rd galaxy')


    
    ############################################################################
    # Update hole center 4
    ############################################################################

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_center = hole_center + minx3*v2_unit  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):
    
        hole_center_memview[0,idx] += minx3*v2_unit_memview[idx]

    #---------------------------------------------------------------------------
    ############################################################################




    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_radius = np.linalg.norm(hole_center - w_coord[k1g])  # shape ()
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    temp_f64_accum = 0.0

    for idx in range(3):

        temp_f64_val = hole_center_memview[0,idx] - w_coord[k1g,idx]

        temp_f64_accum += temp_f64_val*temp_f64_val

    hole_radius = sqrt(temp_f64_accum)

    #---------------------------------------------------------------------------
    ############################################################################




    # Check to make sure that the hole center is still within the survey
    if not_in_mask(hole_center_memview, mask, min_dist, max_dist):
        #print('hole not in survey')
        
        #put_start = time.time()
        
        #return_queue.put(("data", (None, None, None, None)))
        
        #time_returning += time.time() - put_start
        
        #continue
    
        return_array[0] = NAN
        return_array[1] = NAN
        return_array[2] = NAN
        return_array[3] = NAN
        
        return 






    ########################################################################
    #
    # Find Galaxy 4 
    #
    # Process is very similar as before, except we do not know if we have to 
    # move above or below the plane.  Therefore, we will find the next closest 
    # if we move above the plane, and the next closest if we move below the 
    # plane.
    ########################################################################




    # The vector along which to move the hole center is defined by the cross 
    # product of the vectors pointing between the three nearest galaxies.

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    AB = np.subtract(w_coord[k1g], w_coord[k2g])  # shape (3,)
    BC = np.subtract(w_coord[k3g], w_coord[k2g])  # shape (3,)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):

        AB_memview[idx] = w_coord[k1g, idx] - w_coord[k2g, idx]

        BC_memview[idx] = w_coord[k3g, idx] - w_coord[k2g, idx]

    #---------------------------------------------------------------------------
    ############################################################################





    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    v3 = np.cross(AB,BC)  # shape (3,)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    v3_memview[0] = AB_memview[1]*BC_memview[2] - AB_memview[2]*BC_memview[1]

    v3_memview[1] = AB_memview[2]*BC_memview[0] - AB_memview[0]*BC_memview[2]

    v3_memview[2] = AB_memview[0]*BC_memview[1] - AB_memview[1]*BC_memview[0]

    #---------------------------------------------------------------------------
    ############################################################################


    
    

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    modv3 = np.linalg.norm(v3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    temp_f64_accum = 0.0

    for idx in range(3):

        temp_f64_accum += v3_memview[idx]*v3_memview[idx]

    modv3 = sqrt(temp_f64_accum)

    #---------------------------------------------------------------------------
    ############################################################################





    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    v3_unit = v3/modv3  # shape (3,)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):

        v3_unit_memview[idx] = v3_memview[idx]/modv3

    #---------------------------------------------------------------------------
    ############################################################################






    # Calculate vector pointing from the hole center to the nearest galaxy

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    Acenter = np.subtract(w_coord[k1g], hole_center)  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):

        Acenter_memview[idx] = w_coord[k1g, idx] - hole_center_memview[0, idx]

    #---------------------------------------------------------------------------
    ############################################################################





    # Calculate vector pointing from the hole center to the second-nearest galaxy

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    Bcenter = np.subtract(w_coord[k2g], hole_center)  # shape (1,3)
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #
    # CAN PROBABLY COMBINE WITH PREVIOUS FOR-LOOP
    #---------------------------------------------------------------------------

    for idx in range(3):

        Bcenter_memview[idx] = w_coord[k2g, idx] - hole_center_memview[0, idx]

    #---------------------------------------------------------------------------
    ############################################################################





    # First move in the direction of the unit vector defined above

    galaxy_search = True

    in_mask_41 = True





    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_center_41 = hole_center
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):

        hole_center_41_memview[0, idx] = hole_center_memview[0, idx]

    #---------------------------------------------------------------------------
    ############################################################################




    while galaxy_search:




        # Shift hole center along unit vector

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center_41 = hole_center_41 + dr*v3_unit
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_41_memview[0, idx] = hole_center_41_memview[0, idx] + dr*v3_unit_memview[idx]

        #-----------------------------------------------------------------------
        ########################################################################





        # New hole "radius"

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        search_radius = np.linalg.norm(w_coord[k1g] - hole_center_41)
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        temp_f64_accum = 0.0

        for idx in range(3):

            temp_f64_val = w_coord[k1g, idx] - hole_center_41_memview[0, idx]

            temp_f64_accum += temp_f64_val*temp_f64_val

        search_radius = sqrt(temp_f64_accum)

        #-----------------------------------------------------------------------
        ########################################################################





        # Search for nearest neighbors within R of the hole center
        i_nearest = galaxy_tree.query_radius(hole_center_41_memview, r=search_radius)

        i_nearest = i_nearest[0]

        # Remove two nearest galaxies from list
        boolean_nearest = np.logical_and.reduce((i_nearest != k1g, i_nearest != k2g, i_nearest != k3g))

        i_nearest = i_nearest[boolean_nearest]

        #num_nearest is int of ITYPE_t
        num_nearest = i_nearest.shape[0]

        if num_nearest > 0:
            # Found at least one other nearest neighbor!

            i_nearest_memview = i_nearest  # Needed for cython only




            # Calculate vector pointing from hole center to next nearest galaxies

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            temp_1 = np.take(w_coord, i_nearest, axis=0)

            Dcenter = np.subtract(temp_1, hole_center)  # shape (N,3)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------

            Dcenter_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):

                temp_idx = i_nearest_memview[idx]

                for jdx in range(3):

                    Dcenter_memview[idx, jdx] = w_coord[temp_idx, jdx] - hole_center_memview[0, jdx]

            #-------------------------------------------------------------------
            ####################################################################
            
            



            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            bot = 2*np.dot((Dcenter - Acenter), v3_unit.T)  # shape (N,)
            # Different shape than previous bot's because v3_unit has a different shape
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE BELOW FOR-LOOPS
            #-------------------------------------------------------------------

            bot_memview = np.empty(num_nearest, dtype=np.float64, order='C')


            D_minus_A_center_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                for jdx in range(3):
                    
                    D_minus_A_center_memview[idx, jdx] = Dcenter_memview[idx, jdx] - Acenter_memview[jdx]

            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += D_minus_A_center_memview[idx,jdx]*v3_unit_memview[jdx]
                    
                bot_memview[idx] = 2*temp_f64_accum
            
            #-------------------------------------------------------------------
            ####################################################################





            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            top = np.sum(Dcenter**2, axis=1) - np.sum(Bcenter**2)  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE BELOW FOR-LOOPS
            #-------------------------------------------------------------------
            
            top_memview = np.empty(num_nearest, dtype=np.float64, order='C')

            
            temp_f64_accum = 0.0
            
            for idx in range(3):
                
                temp_f64_accum += Bcenter_memview[idx]*Bcenter_memview[idx]
                
            temp_f64_val = temp_f64_accum
            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += Dcenter_memview[idx,jdx]*Dcenter_memview[idx,jdx]
                    
                top_memview[idx] = temp_f64_accum - temp_f64_val
            
            #-------------------------------------------------------------------
            ####################################################################





            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            x41 = top/bot  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------

            x41_memview = np.empty(num_nearest, dtype=np.float64, order='C')

            for idx in range(num_nearest):

                x41_memview[idx] = top_memview[idx]/bot_memview[idx]

            #-------------------------------------------------------------------
            ####################################################################




            

            # Locate positive values of x41

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            valid_idx = np.where(x41 > 0)[0]  # shape (n,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            any_valid = 0
            
            valid_min_idx = 0
            
            valid_min_val = INFINITY
            
            #valid_idx_memview = np.empty(num_nearest, dtype=np.uint8, order='C')
            
            for idx in range(num_nearest):
                
                temp_f64_val = x41_memview[idx]
                
                if temp_f64_val > 0.0:
                    
                    #valid_idx_memview[idx] = 1
                    
                    any_valid = 1
                    
                    if temp_f64_val < valid_min_val:
                        
                        valid_min_idx = idx
                        
                        valid_min_val = temp_f64_val

            #-------------------------------------------------------------------
            ####################################################################




            #debug_1 = len(valid_idx) > 0

            ####################################################################
            # Python version
            #
            # CANNOT KEEP DUE TO FLAGS SET IN IF-BLOCK
            #-------------------------------------------------------------------
            '''
            if len(valid_idx) > 0:
                # Find index of 4th nearest galaxy
                k4g1_x41 = valid_idx[x41[valid_idx].argmin()]
                k4g1 = i_nearest[k4g1_x41]

                minx41 = x41[k4g1_x41]

                galaxy_search = False
            '''

            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            if any_valid:
                
                #used to index into the BA distance array
                k4g1_x41 = valid_min_idx
                
                #used to index into the w_coord array
                k4g1 = i_nearest_memview[valid_min_idx]

                # ???????
                minx41 = x41_memview[k4g1_x41]
                
                galaxy_search = False
            
            #-------------------------------------------------------------------
            ####################################################################
            '''
            print('---------------------------------')
            print('Is there an x41 > 0?', debug_1, any_valid)
            print('k4g1_x41:', k4g1_x41, k4g1_x41_cython)
            print('k4g1:', k4g1, k4g1_cython)
            print('minx41:', minx41, minx41_cython)
            print('x41:', x41, np.asarray(x41_memview, dtype=np.float64, order='C'))
            print('top:', top, np.asarray(top_memview, dtype=np.float64, order='C'))
            print('bot:', bot, np.asarray(bot_memview, dtype=np.float64, order='C'))
            '''



        
        elif not_in_mask(hole_center_41_memview, mask, min_dist, max_dist):
            # Hole is no longer within survey limits
            galaxy_search = False
            in_mask_41 = False

    #print('Found first potential 4th galaxy')
    

    # Calculate potential new hole center
    if in_mask_41:





        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center_41 = hole_center + minx41*v3_unit  # shape (1,3)
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_41_memview[0, idx] = hole_center_memview[0, idx] + minx41*v3_unit_memview[idx]

        #-----------------------------------------------------------------------
        ########################################################################





        
   
    ############################################################################
    # Repeat same search, but shift the hole center in the other direction 
    # this time
    ############################################################################




    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    v3_unit = -v3_unit
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):

        v3_unit_memview[idx] *= -1.0

    #---------------------------------------------------------------------------
    ############################################################################





    # First move in the direction of the unit vector defined above
    galaxy_search = True




    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    # Initialize minx42 (in case it does not get created later)
    minx42 = np.infty
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    minx42 = INFINITY

    #---------------------------------------------------------------------------
    ############################################################################





    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_center_42 = hole_center
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    for idx in range(3):

        hole_center_42_memview[0, idx] = hole_center_memview[0, idx]

    #---------------------------------------------------------------------------
    ############################################################################





    in_mask_42 = True

    while galaxy_search:




        # Shift hole center along unit vector

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center_42 = hole_center_42 + dr*v3_unit
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_42_memview[0, idx] += dr*v3_unit_memview[idx]

        #-----------------------------------------------------------------------
        ########################################################################





        # New hole "radius"

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        search_radius = np.linalg.norm(w_coord[k1g] - hole_center_42)
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        temp_f64_accum = 0.0

        for idx in range(3):

            temp_f64_val = w_coord[k1g, idx] - hole_center_42_memview[0, idx]

            temp_f64_accum += temp_f64_val*temp_f64_val

        search_radius = sqrt(temp_f64_accum)

        #-----------------------------------------------------------------------
        ########################################################################





        # Search for nearest neighbors within R of the hole center
        i_nearest = galaxy_tree.query_radius(hole_center_42_memview, r=search_radius)

        i_nearest = i_nearest[0]

        # Remove three nearest galaxies from list
        boolean_nearest = np.logical_and.reduce((i_nearest != k1g, i_nearest != k2g, i_nearest != k3g))

        i_nearest = i_nearest[boolean_nearest]

        #num_nearest is int of ITYPE_t
        num_nearest = i_nearest.shape[0]

        if num_nearest > 0:
            # Found at least one other nearest neighbor!

            i_nearest_memview = i_nearest  # Needed for cython only





            # Calculate vector pointing from hole center to next nearest galaxies

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            temp_1 = np.take(w_coord, i_nearest, axis=0)
            
            Dcenter = np.subtract(temp_1, hole_center)  # shape (N,3)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------

            Dcenter_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):

                temp_idx = i_nearest_memview[idx]

                for jdx in range(3):

                    Dcenter_memview[idx, jdx] = w_coord[temp_idx, jdx] - hole_center_memview[0, jdx]

            #-------------------------------------------------------------------
            ####################################################################






            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            bot = 2*np.dot((Dcenter - Acenter), v3_unit.T)  # shape (N,)
            # Different shape than previous bot's because v3_unit has a different shape
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE BELOW FOR-LOOPS
            #-------------------------------------------------------------------

            bot_memview = np.empty(num_nearest, dtype=np.float64, order='C')


            D_minus_A_center_memview = np.empty((num_nearest, 3), dtype=np.float64, order='C')
            
            for idx in range(num_nearest):
                
                for jdx in range(3):
                    
                    D_minus_A_center_memview[idx, jdx] = Dcenter_memview[idx, jdx] - Acenter_memview[jdx]

            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += D_minus_A_center_memview[idx,jdx]*v3_unit_memview[jdx]
                    
                bot_memview[idx] = 2*temp_f64_accum
            
            #-------------------------------------------------------------------
            ####################################################################





            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            top = np.sum(Dcenter**2, axis=1) - np.sum(Bcenter**2)  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #
            # CAN PROBABLY CONSOLIDATE BELOW FOR-LOOPS
            #-------------------------------------------------------------------
            
            top_memview = np.empty(num_nearest, dtype=np.float64, order='C')

            
            temp_f64_accum = 0.0
            
            for idx in range(3):
                
                temp_f64_accum += Bcenter_memview[idx]*Bcenter_memview[idx]
                
            temp_f64_val = temp_f64_accum
            
            for idx in range(num_nearest):
                
                temp_f64_accum = 0.0
                
                for jdx in range(3):
                    
                    temp_f64_accum += Dcenter_memview[idx,jdx]*Dcenter_memview[idx,jdx]
                    
                top_memview[idx] = temp_f64_accum - temp_f64_val
            
            #-------------------------------------------------------------------
            ####################################################################






            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            x42 = top/bot  # shape (N,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------

            x42_memview = np.empty(num_nearest, dtype=np.float64, order='C')

            for idx in range(num_nearest):

                x42_memview[idx] = top_memview[idx]/bot_memview[idx]

            #-------------------------------------------------------------------
            ####################################################################






            # Locate positive values of x42

            ####################################################################
            # Python version
            #-------------------------------------------------------------------
            '''
            valid_idx = np.where(x42 > 0)[0]  # shape (n,)
            '''
            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            any_valid = 0
            
            valid_min_idx = 0
            
            valid_min_val = INFINITY
            
            #valid_idx_memview = np.empty(num_nearest, dtype=np.uint8, order='C')
            
            for idx in range(num_nearest):
                
                temp_f64_val = x42_memview[idx]
                
                if temp_f64_val > 0.0:
                    
                    #valid_idx_memview[idx] = 1
                    
                    any_valid = 1
                    
                    if temp_f64_val < valid_min_val:
                        
                        valid_min_idx = idx
                        
                        valid_min_val = temp_f64_val

            #-------------------------------------------------------------------
            ####################################################################







            ####################################################################
            # Python version
            #
            # CANNOT KEEP DUE TO FLAGS SET IN IF-BLOCK
            #-------------------------------------------------------------------
            '''
            if len(valid_idx) > 0:
                # Find index of 3rd nearest galaxy
                k4g2_x42 = valid_idx[x42[valid_idx].argmin()]
                k4g2 = i_nearest[k4g2_x42]

                minx42 = x42[k4g2_x42]

                galaxy_search = False
            '''

            #-------------------------------------------------------------------
            # Cython version
            #-------------------------------------------------------------------
            
            if any_valid:
                
                #used to index into the BA distance array
                k4g2_x42 = valid_min_idx
                
                #used to index into the w_coord array
                k4g2 = i_nearest_memview[valid_min_idx]

                # ???????
                minx42 = x42_memview[k4g2_x42]
                
                galaxy_search = False
            
            #-------------------------------------------------------------------
            ####################################################################





        elif not_in_mask(hole_center_42_memview, mask, min_dist, max_dist):
            # Hole is no longer within survey limits
            galaxy_search = False
            in_mask_42 = False

    #print('Found second potential 4th galaxy')




    # Calculate potential new hole center

    if in_mask_42:

        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center_42 = hole_center + minx42*v3_unit  # shape (1,3)
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_42_memview[0, idx] = hole_center_memview[0, idx] + minx42*v3_unit_memview[idx]

        #-----------------------------------------------------------------------
        ########################################################################


    
    
    ############################################################################
    # Figure out which is the real galaxy 4
    ############################################################################
    
    # Determine which is the 4th nearest galaxy
    not_in_mask_41 = not_in_mask(hole_center_41_memview, mask, min_dist, max_dist)

    if not not_in_mask_41 and minx41 <= minx42:
        # The first 4th galaxy found is the next closest





        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center = hole_center_41
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_memview[0, idx] = hole_center_41_memview[0, idx]

        #-----------------------------------------------------------------------
        ########################################################################




        k4g = k4g1

    elif not not_in_mask(hole_center_42_memview, mask, min_dist, max_dist):
        # The second 4th galaxy found is the next closest




        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center = hole_center_42
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_memview[0, idx] = hole_center_42_memview[0, idx]

        #-----------------------------------------------------------------------
        ########################################################################




        k4g = k4g2

    elif not not_in_mask_41:
        # The first 4th galaxy found is the next closest
        



        ########################################################################
        # Python version
        #-----------------------------------------------------------------------
        '''
        hole_center = hole_center_41
        '''
        #-----------------------------------------------------------------------
        # Cython version
        #-----------------------------------------------------------------------

        for idx in range(3):

            hole_center_memview[0, idx] = hole_center_41_memview[0, idx]

        #-----------------------------------------------------------------------
        ########################################################################




        k4g = k4g1
    else:
        # Neither hole center is within the mask - not a valid hole
        return_array[0] = NAN
        return_array[1] = NAN
        return_array[2] = NAN
        return_array[3] = NAN
        
        return 






    ############################################################################
    # Calculate Radius of the hole
    ############################################################################

    ############################################################################
    # Python version
    #---------------------------------------------------------------------------
    '''
    hole_radius = np.linalg.norm(hole_center - w_coord[k1g])
    '''
    #---------------------------------------------------------------------------
    # Cython version
    #---------------------------------------------------------------------------

    temp_f64_accum = 0.0

    for idx in range(3):

        temp_f64_val = hole_center_memview[0, idx] - w_coord[k1g, idx]

        temp_f64_accum += temp_f64_val*temp_f64_val

    hole_radius = sqrt(temp_f64_accum)

    #---------------------------------------------------------------------------
    ############################################################################








    ########################################################################
    # Save hole
    ########################################################################

    '''
    x_val = hole_center[0,0]
    
    y_val = hole_center[0,1]
    
    z_val = hole_center[0,2]
    
    r_val = hole_radius
    '''
    
    #hole_times.append(time.time() - hole_start)
    
    #print(hole_times[n_holes], i,j,k)
    
    #n_holes += 1
    
    #put_start = time.time()
    
    #return_queue.put(("data", (x_val, y_val, z_val, r_val)))
    
    #time_returning += time.time() - put_start

    return_array[0] = hole_center_memview[0, 0]
    return_array[1] = hole_center_memview[0, 1]
    return_array[2] = hole_center_memview[0, 2]
    return_array[3] = hole_radius
    
    return 


    #return (x_val, y_val, z_val, r_val)






cdef DTYPE_F64_t RtoD = 180./np.pi
cdef DTYPE_F64_t DtoR = np.pi/180.
cdef DTYPE_F64_t dec_offset = -90


@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef DTYPE_B_t not_in_mask(DTYPE_F64_t[:,:] coordinates, 
                  DTYPE_B_t[:,:,:] survey_mask_ra_dec, 
                  DTYPE_F64_t rmin, 
                  DTYPE_F64_t rmax):
    '''
    Determine whether a given set of coordinates falls within the survey.

    Parameters:
    ============

    coordinates : numpy.ndarray of shape (3,), in x-y-z order and cartesian coordinates
        x,y, and z are measured in Mpc/h

    survey_mask_ra_dec : numpy.ndarray of shape (num_ra, num_dec) where 
        the element at [i,j] represents whether or not the ra corresponding to
        i and the dec corresponding to j fall within the mask.  ra and dec
        are both measured in degrees.

    rmin, rmax : scalar, min and max values of survey distance in units of
        Mpc/h

    Returns:
    ========

    boolean : True if coordinates fall outside the survey_mask
    '''



    #print("Coordinates")
    #print(coordinates)
    #print(type(coordinates))
    #print(coordinates.shape)
    
    
    
    cdef DTYPE_F64_t r
    cdef DTYPE_F64_t ra
    cdef DTYPE_F64_t dec
    
    cdef ITYPE_t n
    cdef DTYPE_F64_t n_float
    
    
    cdef ITYPE_t idx1
    cdef ITYPE_t idx2
    
    cdef DTYPE_F64_t coord_x
    cdef DTYPE_F64_t coord_y
    cdef DTYPE_F64_t coord_z
    
    cdef DTYPE_B_t return_mask_value

    #coords = coordinates[0]  # Convert shape from (1,3) to (3,)
    
    #r = np.linalg.norm(coordinates[0,:])
    
    coord_x = coordinates[0,0]
    coord_y = coordinates[0,1]
    coord_z = coordinates[0,2]
    
    
    r = sqrt(coord_x*coord_x + coord_y*coord_y + coord_z*coord_z)
    
    
    
    
    

    if r < rmin or r > rmax:
        
        return True


    n = 1 + <ITYPE_t>(DtoR*r/10.)
    
    n_float = <DTYPE_F64_t>n
    
    #ra = np.arctan(coordinates[0,1]/coordinates[0,0])*RtoD
    
    ra = atan(coord_y/coord_x)*RtoD
    
    #dec = np.arcsin(coordinates[0,2]/r)*RtoD
    
    dec = asin(coord_z/r)*RtoD
    

    if coord_x < 0.0 and coord_y != 0.0:
        
        ra += 180.0
        
    if ra < 0:
        
        ra += 360.0
        
        
    idx1 = <ITYPE_t>(n_float*ra)
    
    idx2 = <ITYPE_t>(n_float*dec) - <ITYPE_t>(n_float*dec_offset)
    
    
    #return_mask_value = survey_mask_ra_dec[n-1][idx1][idx2]
    
    return_mask_value = survey_mask_ra_dec[n-1, idx1, idx2]
    
    
    
    if return_mask_value == 1:
        return_mask_value = 0
    elif return_mask_value == 0:
        return_mask_value = 1

    return return_mask_value






################################################################################
################################################################################



