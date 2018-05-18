/** \file HSFApplicationPath.h
 *  \brief C++ interface to binreloc and resource paths
*/

#ifndef HSFRELOC_HH
#define HSFRELOC_HH

#include <string>

namespace HSFReloc {
//! Return path to running executable
const std::string& getApplicationDir();

//! Return path to resource directory for this executable
const std::string& getResourceDir();
}

#endif // HSFRELOC_HH

