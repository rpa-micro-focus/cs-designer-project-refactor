########################################################################################################################
#!!
#! @description: Renames a flow / operation or moves it to another folder or does both.
#!               To rename a flow / operation, keep the same namespace.
#!               To move the flow / operation, change the namespace.
#!               To do both, rename the flow / operation as well as the namespace.
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: move_flow
  inputs:
    - session_token: '40930'
    - old_flow_name: io.cloudslang.microfocus.rpa.demo.deploy_cps2
    - new_flow_name: io.cloudslang.microfocus.rpa.demo.deploy_cps2
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
            - action: MOVE_FLOW
            - project_folders: "${str([get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/workspace' for ws_user in eval(ws_users)])}"
            - old_name: '${old_flow_name}'
            - new_name: '${new_flow_name}'
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
        x: 41
        'y': 77
      refactor:
        x: 237
        'y': 80
        navigate:
          616a6be7-f862-4e7f-2a3c-fac6221e2841:
            targetId: 876e4e15-5b89-94b5-5c9b-21b7d26cf9a7
            port: SUCCESS
    results:
      SUCCESS:
        876e4e15-5b89-94b5-5c9b-21b7d26cf9a7:
          x: 465
          'y': 80
