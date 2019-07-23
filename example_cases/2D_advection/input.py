#!/usr/bin/python

# Dependencies and Logistics ===================================================

# Command to navigate between directories
from os import chdir

# Command to acquire directory path
from os.path import dirname

# Command to acquire script name and module search path
from sys import argv, path

# Navigating to script directory
if len(dirname(argv[0])) != 0: chdir(dirname(argv[0]))

# Adding master_scripts directory to module search path
mfc_dir = '../../src'; path[:0] = [mfc_dir + '/master_scripts']

# Command to execute the MFC components
from m_python_proxy import f_execute_mfc_component

# Serial or parallel computational engine
engine = 'serial'
# ==============================================================================

# Case Analysis Configuration ==================================================

# Selecting MFC component
comp_name = argv[1].strip()

# Configuring case dictionary
case_dict =                                                                    \
    {                                                                          \
                    # Logistics ================================================
                    'case_dir'                     : '\'.\'',                  \
                    'run_time_info'                : 'T',                      \
                    'nodes'                        : 1,                        \
                    'ppn'                          : 1,                        \
                    'queue'                        : 'normal',                 \
                    'walltime'                     : '24:00:00',               \
                    'mail_list'                    : '',                       \
                    # ==========================================================
                                                                               \
                    # Computational Domain Parameters ==========================
                    'x_domain%beg'                 : 0.E+00,                   \
                    'x_domain%end'                 : 1.E+00,                   \
                    'y_domain%beg'                 : 0.E+00,                  \
                    'y_domain%end'                 : 1.E+00,                  \
                    'm'                            : 99,                       \
                    'n'                            : 99,                       \
                    'p'                            : 0,                        \
                    'dt'                           : 5.E-07,                   \
                    't_step_start'                 : 0,                        \
                    't_step_stop'                  : 1000,                     \
                    't_step_save'                  : 100,                     \
		    # ==========================================================
                                                                               \
                    # Simulation Algorithm Parameters ==========================
                    'num_patches'                  : 2,                        \
                    'model_eqns'                   : 3,                        \
                    'alt_soundspeed'               : 'F',                      \
                    'num_fluids'                   : 2,                        \
	            'adv_alphan'                   : 'T',                      \
	            'mpp_lim'                      : 'T',                      \
	            'mixture_err'                  : 'T',                      \
	            'time_stepper'                 : 3,                        \
                    'weno_vars'                    : 2,                        \
                    'weno_order'                   : 5,                        \
                    'weno_eps'                     : 1.E-16,                   \
                    'char_decomp'                  : 'F',                      \
                    'mapped_weno'                  : 'T',                      \
                    'null_weights'                 : 'F',                      \
                    'mp_weno'                      : 'F',                      \
                    'weno_avg'                     : 'F',                      \
	            'riemann_solver'               : 2,                        \
                    'wave_speeds'                  : 1,                        \
                    'avg_state'                    : 2,                        \
                    'commute_err'                  : 'F',                      \
                    'split_err'                    : 'F',                      \
                    'reg_eps'                      : 1.E+00,                   \
                    'bc_x%beg'                     : -3,                       \
                    'bc_x%end'                     : -3,                       \
                    'bc_y%beg'                     : -3,                       \
                    'bc_y%end'                     : -3,                       \
                    # ==========================================================
                                                                               \
                    # Formatted Database Files Structure Parameters ============
                    'format'                       : 1,                        \
                    'precision'                    : 2,                        \
                    'prim_vars_wrt'                :'T',                       \
		    'parallel_io'                  :'F',                       \
		    # ==========================================================
                                                                                
		    # Patch 1: Base ============================================
                    'patch_icpp(1)%geometry'       : 3,                        \
                    'patch_icpp(1)%x_centroid'     : 0.5E+00,                  \
                    'patch_icpp(1)%y_centroid'     : 0.5E+00,                  \
                    'patch_icpp(1)%length_x'       : 1.E+00,                   \
                    'patch_icpp(1)%length_y'       : 1.E+00,                   \
                    'patch_icpp(1)%vel(1)'         : 100.E+00,                 \
                    'patch_icpp(1)%vel(2)'         : 100.E+00,                 \
                    'patch_icpp(1)%pres'           : 1.E+05,                   \
                    'patch_icpp(1)%alpha_rho(1)'   : 1000.E+00,                \
                    'patch_icpp(1)%alpha_rho(2)'   : 1.,                   \
                    'patch_icpp(1)%alpha(1)'       : 1.E-12,                   \
                    'patch_icpp(1)%alpha(2)'       : 1. - 1.E-12,                   \
                    # ==========================================================

                    # Patch 2: Density to transport ============================
                    'patch_icpp(2)%geometry'       : 2,                        \
                    'patch_icpp(2)%smoothen'       : 'T',                      \
                    'patch_icpp(2)%smooth_patch_id' : 1,                       \
                    'patch_icpp(2)%smooth_coeff'   : 0.5E+00,                  \
                    'patch_icpp(2)%x_centroid'     : 0.1E+00,                  \
                    'patch_icpp(2)%y_centroid'     : 0.1E+00,                  \
                    'patch_icpp(2)%radius'         : 0.1E+00,                  \
                    'patch_icpp(2)%alter_patch(1)' : 'T',                      \
                    'patch_icpp(2)%vel(1)'         : 100.E+00,                 \
                    'patch_icpp(2)%vel(2)'         : 100.E+00,                 \
                    'patch_icpp(2)%pres'           : 1.E+05,                   \
                    'patch_icpp(2)%alpha_rho(1)'   : 1.,                   \
                    'patch_icpp(2)%alpha_rho(2)'   : 1.0,                   \
                    'patch_icpp(2)%alpha(1)'       : 0,                   \
                    'patch_icpp(2)%alpha(2)'       : 1.,                   \
                    # ==========================================================
 
		    # Fluids Physical Parameters ===============================
                    'fluid_pp(1)%gamma'            : 1.E+00/(2.35E+00-1.E+00),  \
                    'fluid_pp(1)%pi_inf'           : 2.35E+00*1.E+09/(2.35E+00-1.E+00), \
                    'fluid_pp(2)%gamma'            : 1.E+00/(1.4E+00-1.E+00),  \
                    'fluid_pp(2)%pi_inf'           : 0.E+00,                   \
	            # ==========================================================

    }

# Executing MFC component
f_execute_mfc_component(comp_name, case_dict, mfc_dir, engine)

# ==============================================================================
