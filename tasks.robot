*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     Collections
Library     RPA.JSON
Library     RPA.Database
Library     RPA.HTTP
Library    RPA.FileSystem
Library    OperatingSystem


*** Variables ***
${API_URL}    http://192.168.9.62:5000
${BOOK_ID}    ${EMPTY}
${IP_ADDRESS}   ${EMPTY}
${USERNAME}     ${EMPTY}
${PASSWORD}     ${EMPTY}

*** Test Cases ***
Get JSON Data From API
    ${book_id}=    Set Variable    ${BOOK_ID}
    ${ip_address}=    Set Variable    ${IP_ADDRESS}
    ${username}=    Set Variable    ${USERNAME}
    ${password}=    Set Variable    ${PASSWORD}
    # Lakukan permintaan ke endpoint API
    Create Session    mysession    ${API_URL}    verify=${False}
    ${response}=    GET On Session    mysession    /api/getBookSinopsis/${book_id}
    ${json_data}=    Convert To Dictionary    ${response.content}
    Log To Console    Full JSON Response: ${json_data}

    # Pindahkan data ke variabel yang lebih spesifik
    ${JUDUL}=    Get From Dictionary    ${json_data}    judul
    ${PENGARANG}=    Get From Dictionary    ${json_data}    pengarang
    ${PENERBITAN}=    Get From Dictionary    ${json_data}    penerbitan
    ${DESC}=    Get From Dictionary    ${json_data}    deskripsi
    ${ISBN}=    Get From Dictionary    ${json_data}    isbn

    # Log untuk verifikasi
    # Log To Console    Judul: ${JUDUL}
    # Log To Console    Pengarang: ${PENGARANG}
    # Log To Console    Penerbitan: ${PENERBITAN}
    # Log To Console    Deskripsi: ${DESC}
    # Log To Console    ISBN: ${ISBN}
    # Log To Console    IP Address: ${ip_address}

    Open website    ${ip_address}
    Login website   ${username}    ${password}
    Select Library Location
    Click Submit Button
    Navigate to Entri Katalog
    Input Book Data     ${JUDUL}    ${PENGARANG}    ${PENERBITAN}    ${DESC}    ${ISBN}
    Logout website
    Close Browser



*** Keywords ***
Convert To Dictionary
  [Arguments]    ${json_string}
  ${json_data}=    Evaluate    json.loads('''${json_string}''')    json
  RETURN    ${json_data}

Open website
    [Arguments]    ${ip_address}
    ${url}=    Set Variable    http://${ip_address}/inlislite3/backend/site/login
    Open Available Browser    ${url}

Login website
    [Arguments]    ${username}    ${password}
    Input Text    id:loginform-username    ${username}
    Input Text    id:loginform-password    ${password}
    Click Button    name:login-button

Select Library Location
    Wait Until Element Is Visible    xpath=//span[@id="select2-dynamicmodel-location-container"]    timeout=10s
    Click Element    xpath=//span[@id="select2-dynamicmodel-location-container"]
    Wait Until Element Is Visible    xpath=//li[contains(text(), 'Perpustakaan Pusat')]    timeout=10s
    Click Element    xpath=//li[contains(text(), 'Perpustakaan Pusat')]

Click Submit Button
    Click Button When Visible    //button[@class="btn btn-primary btn-block btn-flat button_login"]

Navigate to Entri Katalog
    Wait Until Element Is Visible
    ...    xpath=//li[@class="treeview"]/a[contains(@href, '/pengkatalogan/katalog/index')]
    ...    timeout=10s
    Click Element    xpath=//li[@class="treeview"]/a[contains(@href, '/pengkatalogan/katalog/index')]
    Wait Until Element Is Visible
    ...    xpath=//li/a[@href='/inlislite3/backend/pengkatalogan/katalog/create?for=cat&rda=0']
    ...    timeout=10s
    Click Element    xpath=//li/a[@href='/inlislite3/backend/pengkatalogan/katalog/create?for=cat&rda=0']

Input Book Data
    #Input Text    TagsValue_245    judul keempat
    #Input Text    TagsValue_100    pengarang keempat
    #Input Text    TagsValue_260_0    penerbitan keempat
    #Input Text    TagsValue_500_0    desc keempat
    #Input Text    TagsValue_020_0    isbn keempat
    [Arguments]    ${judul}    ${pengarang}    ${penerbitan}    ${desc}    ${isbn}
    Wait Until Element Is Visible    id:TagsValue_245    timeout=10s
    Run Keyword and Ignore Error   Execute JavaScript    document.getElementById('TagsValue_245').value += `${judul}`;
    Run Keyword and Ignore Error   Execute JavaScript    document.getElementById('TagsValue_100').value += `${pengarang}`;
    Run Keyword and Ignore Error   Execute JavaScript    document.getElementById('TagsValue_260_0').value += `${penerbitan}`;
    Run Keyword and Ignore Error   Execute JavaScript    document.getElementById('TagsValue_500_0').value += `${desc}`;
    Run Keyword and Ignore Error   Execute JavaScript    document.getElementById('TagsValue_020_0').value += `${isbn}`;
    Click Button    id:btnSave2

Logout Website
    # Wait until modal-backdrop is gone
    Wait Until Element Is Not Visible    css=div.modal-backdrop    timeout=30s

    # Close any SweetAlert popup
    Execute JavaScript    swal.close();

    # Wait for user dropdown to appear and click it
    Wait Until Element Is Visible
    ...    xpath=//li[@class="dropdown user user-menu"]/a[contains(@class, 'dropdown-toggle')]
    ...    timeout=30s
    Click Element    xpath=//li[@class="dropdown user user-menu"]/a[contains(@class, 'dropdown-toggle')]

    # Check if the logout link is in the DOM (even if it's not visible)
    ${logout_element} =    Execute JavaScript
    ...    return document.querySelector("a[href='/inlislite3/backend/site/logout']");
    IF    '${logout_element}' == None
        Fail    Logout link not found in the DOM
    END

    # Directly trigger the logout using JavaScript if the element exists
    Execute JavaScript    document.querySelector("a[href='/inlislite3/backend/site/logout']").click();

Close Browser
    Close All Browsers
