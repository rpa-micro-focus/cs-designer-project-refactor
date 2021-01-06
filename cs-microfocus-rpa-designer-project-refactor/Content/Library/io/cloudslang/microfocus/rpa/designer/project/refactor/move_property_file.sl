########################################################################################################################
#!!
#! @description: Moves property file to another namespace (folder).
#!
#! @input old_namespace: Current namespace the property file belongs to; e.g. io.cloudslang.hpe.oo
#! @input new_namespace: Wanted namespace the property file should belong to; e.g. io.cloudslang.microfocus.rpa
#! @input property_file_name: Name of the property file (including .sl extension)
#!
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: move_property_file
  inputs:
    - session_token
    - old_namespace
    - new_namespace
    - property_file_name
  workflow:
    - get_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.get_session_properties:
            - session_token: '${session_token}'
        publish:
          - ws_users
        navigate:
          - SUCCESS: refactor
          - FAILURE: on_failure
    - refactor:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.refactor:
            - action: MOVE_PROPERTY_FILE
            - project_folders: "${str([get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/workspace' for ws_user in ws_users.split(',')])}"
            - old_name: '${old_namespace}'
            - new_name: '${new_namespace}'
            - property_file_name: '${property_file_name}'
        publish:
          - failure
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - failure: '${failure}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_session_properties:
        x: 79
        'y': 94
      refactor:
        x: 270
        'y': 93
        navigate:
          789c40b7-2ea9-4a7f-a544-101ca4b1188e:
            targetId: 80d15443-fb96-9964-7faf-45789d8d7605
            port: SUCCESS
    results:
      SUCCESS:
        80d15443-fb96-9964-7faf-45789d8d7605:
          x: 459
          'y': 95
