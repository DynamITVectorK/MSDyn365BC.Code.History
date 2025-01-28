// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Security.AccessControl;

permissionsetextension 20108 "D365 BANKING - AMC" extends "D365 BANKING"
{
    Permissions = tabledata "AMC Bank Banks" = RIMD,
                  tabledata "AMC Bank Pmt. Type" = RIMD,
                  tabledata "AMC Banking Setup" = RIMD;
}
