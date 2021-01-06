########################################################################################################################
#!!
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
operation:
  name: add_folder_record
  inputs:
    - projects_files
    - folder_path
    - folder_id
  python_action:
    script: |-
      import json, sys
      try:
          projects_files = eval(projects_files)
          projects_files[0].get('folders')[folder_path] = 'FOLDER:'+folder_id
          new_projects_files = json.dumps(projects_files)
      #    new_projects_files = str(projects_files)
          failure = ''
      except Exception as e:
          failure =  ','.join([str(x) for x in sys.exc_info()])
  outputs:
    - new_projects_files
    - failure
  results:
    - SUCCESS: '${len(failure) == 0}'
    - FAILURE
