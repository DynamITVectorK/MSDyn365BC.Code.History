
PermissionSet 9018 "Azure AD Plan - View"
{
    Access = Public;
    Assignable = false;


    IncludedPermissionSets = "Azure AD Plan - Read",
                             "Upgrade Tags - View";

    Permissions = tabledata Plan = imd,
                  tabledata "User Plan" = imd;
}
