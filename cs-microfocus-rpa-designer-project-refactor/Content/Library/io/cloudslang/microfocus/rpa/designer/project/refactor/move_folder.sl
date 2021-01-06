########################################################################################################################
#!!
#! @description: Renames a folder and moves all flows / operations belonging into it (or any sub-folders of the folder).
#!
#! @input old_namespace: Current folder namespace; e.g. io.cloudslang.hpe.oo
#! @input new_namespace: Wanted folder namespace; e.g. io.cloudslang.microfocus.rpa
#!
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: move_folder
  inputs:
    - session_token:
        required: true
    - old_namespace: io.cloudslang.microfocus.rpa.demo
    - new_namespace: io.cloudslang.microfocus.rpa.demo2
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
            - action: MOVE_FLOWS
            - project_folders: "${str([get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/workspace' for ws_user in ws_users.split(',')])}"
            - old_name: '${old_namespace}'
            - new_name: '${new_namespace}'
        publish:
          - failure
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - failure: '${failure}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_session_properties:
        x: 47
        'y': 76
      refactor:
        x: 256
        'y': 76
        navigate:
          ed4c7e09-2152-698f-5c0d-c6cef428da9f:
            targetId: 19efe1c8-6a66-e968-67d2-c27e80c8e980
            port: SUCCESS
    results:
      SUCCESS:
        19efe1c8-6a66-e968-67d2-c27e80c8e980:
          x: 454
          'y': 76
