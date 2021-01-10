########################################################################################################################
#!!
#! @description: Checks in all changes made in all checked out projects (that belong to the given session) and finishes the session (unless keep_session is true).
#!
#! @input keep_session: If true, all changes are committed but session is not ended so additional changes can be made
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: upload_projects
  inputs:
    - session_token
    - keep_session:
        required: false
  workflow:
    - get_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.get_session_properties:
            - session_token: '${session_token}'
        publish:
          - ws_users
          - properties
        navigate:
          - SUCCESS: loop_users
          - FAILURE: on_failure
    - loop_users:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${ws_users}'
        publish:
          - ws_user: '${result_string}'
        navigate:
          - HAS_MORE: synchronize_files
          - NO_MORE: is_keep_session
          - FAILURE: on_failure
    - is_keep_session:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${keep_session}'
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': delete_session_properties
    - delete_session_properties:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.delete_session_properties:
            - session_token: '${session_token}'
        navigate:
          - SUCCESS: delete_session_folder
          - FAILURE: on_failure
    - delete_session_folder:
        do:
          io.cloudslang.base.filesystem.delete:
            - source: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - synchronize_files:
        do:
          io.cloudslang.microfocus.rpa.designer.project.refactor._operations.synchronize_files:
            - action: UPLOAD
            - ws_user: '${ws_user}'
            - ws_password: '${eval(properties).get(ws_user)}'
            - ws_tenant: "${get_sp('io.cloudslang.microfocus.rpa.idm_tenant')}"
            - session_folder: "${get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token}"
        navigate:
          - SUCCESS: loop_users
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_session_properties:
        x: 28
        'y': 67
      synchronize_files:
        x: 31
        'y': 273
      delete_session_folder:
        x: 620
        'y': 273
        navigate:
          43647429-d7c7-6b95-8d09-97b916d106c8:
            targetId: 44e88453-9627-7953-988b-05eb59d64832
            port: SUCCESS
      loop_users:
        x: 219
        'y': 69
      delete_session_properties:
        x: 443
        'y': 273
      is_keep_session:
        x: 215
        'y': 276
        navigate:
          fdf9341b-072b-6cb6-06e3-1939bebeed2b:
            targetId: 44e88453-9627-7953-988b-05eb59d64832
            port: 'TRUE'
    results:
      SUCCESS:
        44e88453-9627-7953-988b-05eb59d64832:
          x: 440
          'y': 70
