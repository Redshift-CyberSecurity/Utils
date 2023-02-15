# Active Directory Audint Module
This module was built to be used in conjunction with [DSInternals](https://github.com/MichaelGrafnetter/DSInternals). The concept here is to encrypt the output of 
DSInternal as well as either grab the relavant NT Hash for password testing or a domain user profile dump.

The application is a 2 stage process, the first stage is the module here that is the collector, the second stage is held by our Threat Hunting team to deal with the 
data decryption as well as processing. The encryption process requires a specific public and private key to be able to facilitate the encryption and decryption of the
data. 

The public key is avaliable on request

## Requirements
 * Powershell version 5 or greater
 * Domain Controller Access or RSAT tools equivelant (queries the Active Directory module)
 * DSInternals installed
 * Allowed to run powershell as administrator
 * Redshift provided Public key

## How to run
The script has 2 modes built in, first mode is a basic output of user names and NT Hashes and the second is a full user profile output. 

By default, basic mode is enabled and can be run by executing the following:

<code>.\ADUserAuditScript.ps1</code>

To activate full output mode, execute the following:

<code>.\ADUserAuditScript.ps1 -full</code>
