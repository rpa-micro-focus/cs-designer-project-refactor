########################################################################################################################
#!!
#! @description: Retrives session properties.
#!
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
operation:
  name: get_session_properties
  inputs:
    - session_token
    - properties_file:
        private: true
        default: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/session.properties'}"
  python_action:
    script: |-
      import json, sys
      try:
          failure = ''
          with open(properties_file) as json_file:
              try:
                  properties_json = json.load(json_file)
              except ValueError as te:
                  properties_json = {}
              properties = properties_json.get(session_token, None)
              ws_users = '' if properties is None else properties.keys()
      except Exception as e:
          failure =  ','.join([str(x) for x in sys.exc_info()])
  outputs:
    - failure
    - properties: "${'' if properties is None else str(properties)}"
    - ws_users: '${",".join(ws_users)}'
  results:
    - SUCCESS: '${len(failure) == 0}'
    - FAILURE
