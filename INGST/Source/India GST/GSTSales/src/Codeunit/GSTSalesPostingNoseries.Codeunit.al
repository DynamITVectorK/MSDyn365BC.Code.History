codeunit 18142 "GST Sales Posting No. Series"
{
    //No Series for Sales 
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEvent(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        if not Rec.IsTemporary() then begin
            Record := Rec;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
            Rec := Record;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure SelltoCustomer(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer no.', false, false)]
    local procedure BilltoCustomer(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Contact No.', false, false)]
    local procedure SelltoContact(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer Template Code', false, false)]
    local procedure SelltoCustomerTemplateCode(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Contact No.', false, false)]
    local procedure BilltoContact(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer Template Code', false, false)]
    local procedure BilltoCustomerTemplateCode(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Trading', false, false)]
    local procedure Trading(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure Location(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    var
        PostingNoSeries: Record "Posting No. Series";
}