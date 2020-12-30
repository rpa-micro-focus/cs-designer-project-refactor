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
      import json
      try:
          failure = ''
          with open(properties_file) as json_file:
              try:
                  properties_json = json.load(json_file)
              except ValueError as te:
                  properties_json = {}
              properties = properties_json.get(session_token, None)
              ws_users = '' if properties is None else ["'"+x+"'" for x in properties.keys()]
      except Exception as e:
          failure = "%s: %s" % (type(e).__name__, str(e))
  outputs:
    - failure
    - properties: "${'' if properties is None else str(properties)}"
    - ws_users: '${",".join(ws_users)}'
  results:
    - SUCCESS: '${len(failure) == 0}'
    - FAILURE
