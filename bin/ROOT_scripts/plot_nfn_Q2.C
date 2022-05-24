void plot_nfn_Q2( std::string nRun, bool verbatim = false ) 
{
    TCanvas* canvas = new TCanvas( "nfn_Q2", "Final-State Neutrons vs Momentum Transfer" );
    // canvas->SetGrid();

    std::string fileName = "gntp." + nRun + ".gst.root";
    TFile* file = TFile::Open( fileName.c_str() );
    TTree* tree = ( TTree* )file->Get( "gst;1" );
    
    const unsigned int size = tree->GetEntries();
    Double_t nfn [ size ];
    Double_t Q2 [ size ];
    Int_t    cur_nfn;
    Double_t cur_Q2;

    Int_t    max_nfn = 0;
    Double_t max_Q2  = 0;

    tree->SetBranchAddress( "nfn", &cur_nfn );
    tree->SetBranchAddress( "Q2", &cur_Q2 );

    for( Int_t i = 0; i < size; i++ ) {
        tree->GetEntry( i );
        nfn[ i ] = cur_nfn;
        Q2[ i ] = cur_Q2;
        if( cur_nfn > max_nfn ) max_nfn = cur_nfn;
        if( cur_Q2 > max_Q2 ) max_Q2 = cur_Q2;
        
        if( verbatim )
            cout << "(" << nfn[ i ] << "," << Q2[ i ] << ")" << endl;
    }

    cout << "Max Q2: " << max_Q2 << endl;
    cout << "Max nfn: " << max_nfn << endl;

    TGraph* graph = new TGraph( size, Q2, nfn );
    graph->SetTitle( "Neutron Multiplicity vs Momentum Transfer" );
    graph->SetMarkerColor( kRed );
    graph->SetMarkerStyle( 20 );
    graph->SetMarkerSize( 1.7 );

    graph->SetPoint( size, -0.5, -0.5 );

    graph->GetHistogram()->SetAxisRange( max_Q2 / -36, max_Q2 + max_Q2 / 35, "X" );
    graph->GetXaxis()->SetTitle( "Momentum [GeV^2]" );
    graph->GetXaxis()->SetTitleOffset( 1.15 );
    graph->GetHistogram()->SetAxisRange( max_nfn / -20, max_nfn + max_nfn / 20, "Y" );
    graph->GetYaxis()->SetTitle( "Neutron Multiplicity" );
    graph->GetYaxis()->SetTitleOffset( 0.7 );

    graph->Draw( "AP" );
}