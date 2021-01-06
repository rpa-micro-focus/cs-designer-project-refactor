########################################################################################################################
#!!
#! @description: Renames a system property.
#!
#! @input old_property_name: Current property name (e.g. proxy_url)
#! @input new_property_name: Wanted property name (e.g. proxy_host)
#! @input namespace: Namespace the property belongs to; e.g. io.cloudslang.microfocus.rpa
#! @input property_file_name: Name of the property file (including .sl extension)
#!
#! @output failure: Error message in case of failure
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.rpa.designer.project.refactor
flow:
  name: rename_property
  inputs:
    - session_token
    - old_property_name
    - new_property_name
    - namespace
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
            - action: RENAME_PROPERTY
            - project_folders: "${str([get_sp('io.cloudslang.microfocus.rpa.designer.project.refactor.storage_root')+'/'+session_token+'/'+ws_user+'/workspace' for ws_user in ws_users.split(',')])}"
            - old_name: '${old_property_name}'
            - new_name: '${new_property_name}'
            - property_file_name: '${property_file_name}'
            - namespace: '${namespace}'
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
        x: 107
        'y': 102
      refactor:
        x: 303
        'y': 99
        navigate:
          88270e46-014e-4f98-4f68-567952692fa5:
            targetId: b185e869-cd87-3ff3-70c2-547e0a1ab34b
            port: SUCCESS
    results:
      SUCCESS:
        b185e869-cd87-3ff3-70c2-547e0a1ab34b:
          x: 502
          'y': 98
