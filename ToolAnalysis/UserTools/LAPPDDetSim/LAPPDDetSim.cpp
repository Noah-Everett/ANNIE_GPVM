// Vim: set shiftwidth=4

#include "LAPPDDetSim.h"

LAPPDDetSim::LAPPDDetSim():Tool(){}

bool LAPPDDetSim::Initialise( string configfile, DataModel& data ) {
    Log( strcat( LOCATION, "Initializing `LAPPDDetSim`." ), m_ver_debug, m_verbosity );
    /////////////////// Useful header ///////////////////////
    if( configfile != "" ) 
        m_variables.Initialise( configfile ); // Loading config file
    //m_variables.Print();

    m_data = &data; // Assigning transient data pointer
    /////////////////////////////////////////////////////////////////

    return true;
}


bool LAPPDDetSim::Execute() {

    return true;
}


bool LAPPDDetSim::Finalise() {

    return true;
}
