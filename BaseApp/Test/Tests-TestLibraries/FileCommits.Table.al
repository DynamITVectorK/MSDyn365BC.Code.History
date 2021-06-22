table 130027 "File Commits"
{

    fields
    {
        field(1; "File path"; Code[250])
        {
        }
        field(2; "No of commits"; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "File path")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

