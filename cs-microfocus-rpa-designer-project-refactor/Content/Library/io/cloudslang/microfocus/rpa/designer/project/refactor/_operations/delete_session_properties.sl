########################################################################################################################
#!!
#! @description: Deletes sesions properties.
#!
#! @output failure: Error message in case of failure
#! @output properties: Session properties (the just deleted ones)
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
operation:
  name: delete_session_properties
  inputs:
    - session_token
    - properties_file:
        private: true
        default: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/session.properties'}"
  python_action:
    script: |-
      import json
      try:
          failure = ''
          with open(properties_file) as json_file:
              try:
                  properties_json = json.load(json_file)
              except (IOError, ValueError) as te:
                  properties_json = {}
              properties = properties_json.pop(session_token, None)
          with open(properties_file, 'w') as json_file:
              json.dump(properties_json, json_file)
      except Exception as e:
          failure =  ','.join([str(x) for x in sys.exc_info()])
  outputs:
    - failure
    - properties: "${'' if properties is None else str(properties)}"
  results:
    - SUCCESS: '${len(failure) == 0}'
    - FAILURE
