permissionset 4737 "Dynamics CRM - View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Dynamics CRM Integration';

    Permissions = tabledata "CDS Solution" = R,
                  tabledata "CDS Teammembership" = R,
                  tabledata "CDS Teamroles" = R,
                  tabledata "Coupling Field Buffer" = R,
                  tabledata "Coupling Record Buffer" = R,
                  tabledata "CRM Account" = R,
                  tabledata "CRM Account Statistics" = R,
                  tabledata "CRM Annotation" = R,
                  tabledata "CRM Annotation Buffer" = RIMD,
                  tabledata "CRM Annotation Coupling" = RIMD,
                  tabledata "CRM Appmodule" = R,
                  tabledata "CRM Businessunit" = R,
                  tabledata "CRM Connection Setup" = R,
                  tabledata "CRM Contact" = R,
                  tabledata "CRM Contract" = R,
                  tabledata "CRM Customeraddress" = R,
                  tabledata "CRM Discount" = R,
                  tabledata "CRM Discounttype" = R,
                  tabledata "CRM Full Synch. Review Line" = R,
                  tabledata "CRM Incident" = R,
                  tabledata "CRM Incidentresolution" = R,
                  tabledata "CRM Integration Record" = R,
                  tabledata "CRM Invoice" = R,
                  tabledata "CRM Invoicedetail" = R,
                  tabledata "CRM NAV Connection" = R,
                  tabledata "CRM Opportunity" = R,
                  tabledata "CRM Option Mapping" = R,
                  tabledata "CRM Organization" = R,
                  tabledata "CRM Post" = R,
                  tabledata "CRM Post Buffer" = RIMD,
                  tabledata "CRM Post Configuration" = R,
                  tabledata "CRM Pricelevel" = R,
                  tabledata "CRM Product" = R,
                  tabledata "CRM Productpricelevel" = R,
                  tabledata "CRM Quote" = R,
                  tabledata "CRM Quotedetail" = R,
                  tabledata "CRM Redirect" = R,
                  tabledata "CRM Role" = R,
                  tabledata "CRM Salesorder" = R,
                  tabledata "CRM Salesorderdetail" = R,
                  tabledata "CRM Synch. Conflict Buffer" = RIMD,
                  tabledata "CRM Synch. Job Status Cue" = RIMD,
                  tabledata "CRM Systemuser" = R,
                  tabledata "CRM Systemuserroles" = R,
                  tabledata "CRM Team" = R,
                  tabledata "CRM Transactioncurrency" = R,
                  tabledata "CRM Uom" = R,
                  tabledata "CRM Uomschedule" = R,
                  tabledata "Integration Field Mapping" = R,
                  tabledata "Integration Synch. Job" = R,
                  tabledata "Integration Synch. Job Errors" = R,
                  tabledata "Integration Table Mapping" = R;
}