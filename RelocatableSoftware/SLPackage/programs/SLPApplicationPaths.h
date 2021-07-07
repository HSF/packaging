/** \file SLPApplicationPaths.h
 *  \brief C++ interface to binreloc and resource paths
*/

#ifndef SLPAPPLICATIONPATHS_HH
#define SLPAPPLICATIONPATHS_HH

#include <string>

namespace SLP {
//! Return path to running executable
const std::string& getApplicationDir();

//! Return path to resource directory for this executable
const std::string& getResourceDir();
}

#endif // HSFRELOC_HH

