// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Mocking;

dotnet
{
    assembly("Microsoft.Dynamics.Nav.AzureADGraphClient")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.AzureADGraphClient.MockGraphQuery"; "MockGraphQuery")
        {
        }
    }
}