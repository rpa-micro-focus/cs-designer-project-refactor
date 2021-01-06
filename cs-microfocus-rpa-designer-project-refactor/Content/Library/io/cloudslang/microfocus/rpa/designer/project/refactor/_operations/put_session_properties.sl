########################################################################################################################
#!!
#! @description: Adds or replace existing session properties.
#!
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor._operations
operation:
  name: put_session_properties
  inputs:
    - session_token
    - ws_user
    - ws_password:
        required: false
    - properties_file:
        private: true
        default: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/session.properties'}"
  python_action:
    script: "import json, sys\ntry:\n    failure = ''\n    try: \n        with open(properties_file) as json_file:\n            properties_json = json.load(json_file)\n            dict = properties_json.get(session_token)\n            if dict is None:                            # session not found\n                properties_json[session_token] = {ws_user : ws_password}        \n            else:\n                dict[ws_user] = ws_password    \n#                properties_json[session_token] = dict   # todo is it necessary?\n    except (ValueError, IOError):                        # the file is empty (or corrupted) or does not exist\n        properties_json = {}\n        properties_json[session_token] = {ws_user : ws_password}        \n    \n    with open(properties_file, 'w') as json_file:\n        json.dump(properties_json, json_file)\nexcept Exception as e:\n    failure =  ','.join([str(x) for x in sys.exc_info()])"
  outputs:
    - failure
  results:
    - SUCCESS: '${len(failure) == 0}'
    - FAILURE
