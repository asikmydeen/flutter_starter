this is my meeting summary after the demo, [Pasted text #2 +98 lines] lets not worry about
  permissions for now. I wil also give my hand written notes, based on that put an action plan
  to fix all the issues,  1. Expandable qualificataions sidepane, all the categories shown
  and clickable, it should not be hidden and requires scolling. 2. Add a checkbox to get
  acknowledgement that Contact is on NDA with Amazon (we can also show in brackets or help
  text) this is needed for SFSQ contacts creation, 3. In the new request creation screen when
  i change the vendor or remove the vendor in the existing vendor selection, it should update
  all fileds and also clear everything if I cleared that. 4. Do not hide the vendor profile
  pane Supplier profile when entry is selected in Vendor service., we can show and allow
  userss to edit it as well, Also the side pane is cutting off the actual pane, make it
  properly responsively contain, 5. Make website field mandatory 6. When we find duplicates
  i.e. when Salesfore says it found duplicate events, we need to get all the duplicates and
  list them and ask users to select the one they want, if du0licates are found and users are
  not agreeing with the duplicate then we should ask/allow them to edit the vendor name along
  with other field,  as thats one of the field that determines the record in salesforce or
  allow them to discard the request. discarding should be shown properly in the lists for
  items that are discarded. 7. Users can still send a supplier qualification for  a new
  category even though there are existing qualifications for a particualr seller, this should
  be after they have selected from the given duplicates. ( I want you to think here on which
  is the better approach, currently we only check vendor service and then we get details and
  create, (only when creating the entry in salesforce we are seeing the duplicates etc, could
  we do this before itself i.e. before we got all the details and before creating the compass
  request?) SHould show the qualification status for every vendor i.e. L1 Qualified or L2
  Qualified etc, I think this will be in the database and the salesforce seller details list
  can also be fetched from table or through given api.