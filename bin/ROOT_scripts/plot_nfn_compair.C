{
    TCanvas* canvas = new TCanvas( "nfn", "Final-State Neutrons" );
    
    // TFile* file_102 = TFile::Open( "gntp.102.gst.root" );
    TFile* file_103 = TFile::Open( "gntp.103.gst.root" );
    TFile* file_6 = TFile::Open( "gntp.6.gst.root" );

    // TTree* tree_102 = ( TTree* )file_102->Get( "gst;1" );
    TTree* tree_103 = ( TTree* )file_103->Get( "gst;1" );
    TTree* tree_6 = ( TTree* )file_6->Get( "gst;1" );
    
    const unsigned int size = tree_103->GetEntries();
    // int* nfn_2 = new int[ size ];
    // int* nfn_6 = new int[ size ];
    // int nfn_cur_102;
    int nfn_cur_103;
    int nfn_cur_6;
    int c = 0;

    // tree_102->SetBranchAddress( "nfn", &nfn_cur_102 );
    tree_103->SetBranchAddress( "nfn", &nfn_cur_103 );
    tree_6->SetBranchAddress( "nfn", &nfn_cur_6 );

    // TH1F* hist_102 = new TH1F( "WORLD_LV", "Final-State Neutrons", 21, 0, 20 );
    TH1F* hist_103 = new TH1F( "Water Tank", "Final-State Neutrons", 22, 0, 21 );
    TH1F* hist_6 = new TH1F( "Liquid Argon Cylinder", "Final-State Neutrons", 22, 0, 21 );
    
    // Int_t i = 0; 
    // int j = 0;
    for( Int_t i = 0; i < size; i++ )
    {
        // tree_102->GetEntry( i );
        tree_103->GetEntry( i );
        tree_6->GetEntry( i );

        // hist_102->Fill( nfn_cur_102 );
        hist_103->Fill( nfn_cur_103 );
        hist_6->Fill( nfn_cur_6 );

        if( nfn_cur_6 == 0 )
            ++c;
        // nfn_2[ i ] = nfn_cur_2;
        // nfn_6[ i ] = nfn_cur_6;
    }

    // hist_2->SetFillColorAlpha( kGreen+3, 0 );
    // hist_6->SetFillColorAlpha( kBlue-4, 0 );
    // hist_102->SetLineColor( kGreen );
    // cout << c << endl;

    hist_103->SetLineColor( kRed );
    hist_6->SetLineColor( kBlue );

    // hist_102->SetLineWidth( 3 );
    hist_103->SetLineWidth( 5 );
    hist_6->SetLineWidth( 5 );
    
    // hist_102->Scale( .1 );
    // hist_103->Scale( .1 );
    // hist_6->Scale( .1 );

    hist_103->GetXaxis()->SetTitle( "Neutron Multiplicity" );
    hist_103->GetYaxis()->SetTitle( "Events" );


    // THStack* stack = new THStack( "nfn", "Final State Neutrons;Number of Neutrons;Number of Runs" );
    // stack->Add( hist_2 );
    // stack->Add( hist_6 );    

    TLegend* legend = new TLegend( 0.68,0.72,0.98,0.92 );
    // legend->AddEntry( hist_102, "WORLD_LV", "l" );
    legend->AddEntry( hist_103, "Water Tank", "l" );
    legend->AddEntry( hist_6, "Liquid Argon Cylinder", "l" );

    // gStyle->SetOptStat( kTRUE );

    hist_103->Draw("HIST");
    // hist_102->Draw( "Sames HIST" );
    hist_6->Draw( "Sames" );
    legend->Draw( "Sames" );

    // canvas->cd( 0 );
    // legend->Draw();
    // stack->Draw();
    // canvas->cd();
    

    // for( int i = 0; i < size; i++ )
    //     cout << nfn[ i ] << endl;
}