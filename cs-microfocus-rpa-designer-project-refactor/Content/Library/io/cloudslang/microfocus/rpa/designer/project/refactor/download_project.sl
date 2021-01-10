########################################################################################################################
#!!
#! @description: Starts refactoring session or continues in an already started session. It checks out the project of the given user.
#!
#! @input session_token: Do no provide anything when starting a new session; type the session token when continuing in an already started session.
#! @input ws_user: All files from the workspace of this user will be downloaded
#! @input ws_password: Workspace user password
#! @input ws_tenant: Which tenant the user belongs to
#!
#! @output new_session_token: Returns the given or newly created sesstion token (if a new session has started)
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: download_project
  inputs:
    - session_token:
        required: false
    - ws_user: esdev
    - ws_password:
        default: Automation_123
        required: true
        sensitive: true
    - ws_tenant:
        required: false
  workflow:
    - is_token_given:
        do:
          io.cloudslang.base.utils.is_null:
            - variable: '${session_token}'
        navigate:
          - IS_NULL: uuid_generator
          - IS_NOT_NULL: put_session_properties
    - uuid_generator:
        do:
          io.cloudslang.base.utils.uuid_generator: []
        publish:
          - session_token: '${new_uuid[:5]}'
        navigate:
          - SUCCESS: put_session_properties
    - put_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.put_session_properties:
            - session_token: '${session_token}'
            - ws_user: '${ws_user}'
            - ws_password: '${ws_password}'
        publish:
          - session_folder: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token}"
        navigate:
          - SUCCESS: synchronize_files
          - FAILURE: on_failure
    - synchronize_files:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.synchronize_files:
            - action: DOWNLOAD
            - ws_user: "${get('ws_user', get_sp('io.cloudslang.microfocus.rpa.rpa_username'))}"
            - ws_password: "${get('ws_password', get_sp('io.cloudslang.microfocus.rpa.rpa_password'))}"
            - ws_tenant: "${get('ws_tenant', get_sp('io.cloudslang.microfocus.rpa.idm_tenant'))}"
            - session_folder: '${session_folder}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - new_session_token: '${session_token}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_token_given:
        x: 21
        'y': 96
      synchronize_files:
        x: 183
        'y': 95
        navigate:
          c5b99190-60c4-dc92-c302-4b2b8e9c7653:
            targetId: d18a5abe-cad3-e570-25b6-4495b48a7331
            port: SUCCESS
      put_session_properties:
        x: 183
        'y': 263
      uuid_generator:
        x: 20
        'y': 267
    results:
      SUCCESS:
        d18a5abe-cad3-e570-25b6-4495b48a7331:
          x: 377
          'y': 102
