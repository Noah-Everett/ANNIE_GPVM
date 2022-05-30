void plot_nfn_Q2( std::string nRun_argon, std::string nRun_water, bool verbatim = false ) 
{
    TCanvas* canvas = new TCanvas( "nfn_Q2", "Final-State Neutrons vs Momentum Transfer" );
    canvas->SetGrid();

    std::string fileName_argon = "gntp." + nRun_argon + ".gst.root";
    std::string fileName_water = "gntp." + nRun_water + ".gst.root";
    
    TFile* file_argon = TFile::Open( fileName_argon.c_str() );
    TFile* file_water = TFile::Open( fileName_water.c_str() );

    TTree* tree_argon = ( TTree* )file_argon->Get( "gst;1" );
    TTree* tree_water = ( TTree* )file_water->Get( "gst;1" );
    
    const unsigned int size_argon = tree_argon->GetEntries();
    Double_t nfn_argon    [ size_argon ];
    Double_t Q2_argon     [ size_argon ];
    Int_t    cur_nfn_argon;
    Double_t cur_Q2_argon;
    const unsigned int size_water = tree_water->GetEntries();
    Double_t nfn_water    [ size_water ];
    Double_t Q2_water     [ size_water ];
    Int_t    cur_nfn_water;
    Double_t cur_Q2_water;

    Int_t    max_nfn = 0;
    Double_t max_Q2  = 0;

    tree_argon->SetBranchAddress( "nfn", &cur_nfn_argon );
    tree_argon->SetBranchAddress( "Q2",  &cur_Q2_argon );
    tree_water->SetBranchAddress( "nfn", &cur_nfn_water );
    tree_water->SetBranchAddress( "Q2",  &cur_Q2_water );
    
    for( Int_t i = 0; i < size_argon; i++ ) {
        tree_argon->GetEntry( i );
        nfn_argon[ i ] = cur_nfn_argon;
        Q2_argon [ i ] = cur_Q2_argon;
        if( cur_nfn_argon > max_nfn ) max_nfn = cur_nfn_argon;
        if( cur_Q2_argon > max_Q2 )   max_Q2 = cur_Q2_argon;
        
        if( verbatim )
            cout << "(" << nfn_argon[ i ] << "," << Q2_argon[ i ] << ")" << endl;
    }
    for( Int_t i = 0; i < size_water; i++ ) {
        tree_water->GetEntry( i );
        nfn_water[ i ] = cur_nfn_water;
        Q2_water [ i ] = cur_Q2_water;
        if( cur_nfn_water > max_nfn ) max_nfn = cur_nfn_water;
        if( cur_Q2_water > max_Q2 )   max_Q2 = cur_Q2_water;

        if( verbatim )
            cout << "(" << nfn_water[ i ] << "," << Q2_water[ i ] << ")" << endl;
    }

    cout << "Max Q2: "  << max_Q2 << endl;
    cout << "Max nfn: " << max_nfn << endl;

    TMultiGraph* multiGraph = new TMultiGraph();
    multiGraph->SetTitle( "Neutron Multiplicity vs Momentum Transfer" );
    
    TGraph* graph_argon = new TGraph( size_argon, Q2_argon, nfn_argon );
    graph_argon->SetMarkerColor( kRed );
    graph_argon->SetMarkerStyle( 20 );
    graph_argon->SetMarkerSize( 1.7 );
    multiGraph->Add( graph_argon );
    TGraph* graph_water = new TGraph( size_water, Q2_water, nfn_water );
    graph_water->SetMarkerColor( kBlue );
    graph_water->SetMarkerStyle( 20 );
    graph_water->SetMarkerSize( 1.7 );
    multiGraph->Add( graph_water );

    TLegend* legend = new TLegend( 0.651681, 0.806167, 0.899922, 0.9001468 );
    legend->AddEntry( graph_argon, "Liquid Argon Cylinder", "p" );
    legend->AddEntry( graph_water, "Water Tank", "p" );

    multiGraph->GetXaxis()->SetRangeUser( max_Q2 / -35, max_Q2 + max_Q2 / 35 );
    multiGraph->GetXaxis()->SetTitle( "Momentum [GeV^2]" );
    multiGraph->GetXaxis()->SetTitleOffset( 1.15 );
    multiGraph->GetYaxis()->SetRangeUser( max_nfn / -20, max_nfn + max_nfn / 20 );
    multiGraph->GetYaxis()->SetTitle( "Neutron Multiplicity" );
    multiGraph->GetYaxis()->SetTitleOffset( 0.7 );

    multiGraph->Draw( "API" );
    legend->Draw( "Sames" );
}