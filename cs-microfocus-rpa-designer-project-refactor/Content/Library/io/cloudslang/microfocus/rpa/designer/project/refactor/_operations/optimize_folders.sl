########################################################################################################################
#!!
#! @description: Optimize the list of folders so only the leaf nodes are returned (with the longest path).
#!
#! @input folders: List of folders delimited by comma
#!
#! @output optimized_folders: Only leaf nodes
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
operation:
  name: optimize_folders
  inputs:
    - folders
  python_action:
    script: "import sys\ntry:\n    list = folders.split(',')\n    optimized_list = []\n    for f in sorted(list, reverse = True):\n        skip = False\n        for fo in optimized_list:\n            if fo.startswith(f):\n                skip = True\n                break\n        if not skip:\n            optimized_list.append(f)\n    optimized_folders = \",\".join(optimized_list)        \n    failure = ''\nexcept Exception as e:\n    failure =  ','.join([str(x) for x in sys.exc_info()])"
  outputs:
    - optimized_folders
    - failure
  results:
    - SUCCESS: '${len(failure) == 0}'
    - FAILURE
