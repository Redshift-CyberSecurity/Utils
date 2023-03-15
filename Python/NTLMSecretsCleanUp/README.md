# NTLM Secrets Clean Up
This script was built to be used in conjunction with [Impacket\SecretDump](https://github.com/fortra/impacket/blob/master/examples/secretsdump.py). This script takes
the output that has been processed from SecretDump script, its purpose is to clean up the file to be used with a hashing tool. 

This script has autotabbing completion, variable input for delimiter field as well vairable input for the columns in case other fields are required.
By default the script grabs the first and the 4th column and works with the delimiter ":".


## Requirements
 * Python 3.7 or higher
 * Readline (Linux) or PyReadLine3 (Windows) module installed

## How to run

<code>python NTLMSecretsCleanUp.py</code>


<code>Enter path to input file:
  Enter path to output file:
  Enter delimiter used to split columns (or leave blank to use default ':'):
  Enter field numbers to filter (comma-separated, or leave blank to use defaults):
</code>
