// Vim: set shiftwidth=4 

#ifndef LAPPDDetSim_H
#define LAPPDDetSim_H

#include <string>
#include <iostream>

#include "Tool.h"

#define LOCATION "<__FILE__::__FUNCTION (__LINE__)>: "

using std::string;

/**
 * NOTE: I will add Doxygen support in the future
 */

/**
 * \class LAPPDDetSim
 *
 * $Author: N.Everett $
 * $Date: 2022/05/24 08:00:00 $
 * Contact: noah.everett@mines.sdsmt.edu
 */
class LAPPDDetSim: public Tool {
    public:
	LAPPDDetSim();   // Simple constructor
        
	bool Initialise( string configfile, DataModel& data ); // Initialise Function for setting up Tool resources. 
                                                               // @param configfile The path and name of the dynamic configuration file to read in. 
                                                               // @param data A reference to the transient data class used to pass information between Tools.
        bool Execute();  // Execute function used to perform Tool purpose.
	bool Finalise(); // Finalise function used to clean up resources.

    private:
	// Verbosity levels
	      int m_verbosity   = 3;
	const int m_ver_error   = 0;
	const int m_ver_warning = 1;
	const int m_ver_message = 2;
	const int m_ver_debug   = 3;
};

#endif

