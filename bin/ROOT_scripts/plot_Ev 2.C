{
    TCanvas* canvas = new TCanvas( "Ev", "Neutrino Energy" );
    
    TFile* file_6 = TFile::Open( "gntp.6.gst.root" );
    TTree* tree_6 = ( TTree* )file_6->Get( "gst;1" );
    
    const unsigned int size = tree_6->GetEntries();
    double cur_6;
    tree_6->SetBranchAddress( "Ev", &cur_6 );

    TH1F* hist_6 = new TH1F( "", "Neutrino Energy", 120, 0, 6 );
    
    for( Int_t i = 0; i < size; i++ )
    {
        tree_6->GetEntry( i );
        hist_6->Fill( cur_6 );
    }

    hist_6->SetLineColor( kBlue );
    hist_6->SetLineWidth( 3 );
    
    hist_6->Scale( .1 );

    hist_6->GetXaxis()->SetTitle( "Energy [GeV]" );
    hist_6->GetYaxis()->SetTitle( "Counts/0.1Gev" );

    // gStyle->SetOptStat( kTRUE );

    hist_6->Draw();
}