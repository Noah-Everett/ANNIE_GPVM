using std::string;
using std::vector;
using std::map;

const vector< Color_t >     kColors        = { kRed, kBlue, kGreen, kPink };
const map< string, string > kTitles        = { { "nfn", "Final-State Neutrons" } };
const map< string, string > kXaxisTitles   = { { "nfn", "Neutron Multiplicity" } };
const map< string, string > kYaxisTitles   = { { "nfn", "Events" } };
const map< string, string > kBranchVarType = { { "nfn", "int" }, { "Q2", "double" } };

int makeHist( const vector< string >& t_files, const string& t_branch, const string& t_options );

int gstHist( vector< string > t_files, string t_branch, string t_options ) 
{
    for( char option : t_options )
        if( option == 'H' | option == 'h' ) {
            cout << "Usage Statement:" << endl;
            cout << endl;
            cout << "Command line usage:" << endl;
            cout << "$ root -l /path/to/gstHist.C\\(\\{"
                 << "\\\"/path/to/gntp.<file number>.gst.root\\\",...,"
                 << "\\\"/path/to/gntp.<file number>.gst.root\\\"\\},"
                 << "\\\"<branch name>\\\",\\\"<options>\\\"\\)" << endl;
            cout << endl;
            cout << "ROOT usage:" << endl;
            cout << "root [#] .x /path/to/gstHist.C({"
                 << "\"/path/to/gntp.<file number>.gst.root\",...,"
                 << "\"/path/to/gntp.<file number>.gst.root\"},"
                 << "\"<branch name>\",\"<options>\")" << endl;
            cout << endl;

            return 1;
        }

    if( !makeHist( t_files, t_branch, t_options ) ) return 1;

    return 0;
}

int makeHist( const vector< string >& t_files, const string& t_branch, const string& t_options )
{
    bool oPercent = false;
    bool oFill    = false;
    for( char option : t_options ) {
             if( option == 'P' ) oPercent = true;
        else if( option == 'F' ) oFill    = true;
        else {
            cerr << "Invalid char in `t_options`: \"option\". For usage statement include 'H' in `t_options`";
            return 1;
        }
    }

    TCanvas* canvas = new TCanvas( t_branch.c_str(), kTitles.at( t_branch ).c_str() );
    TFile  * file   = TFile::Open( t_files[ 0 ].c_str() );
    TTree  * tree   = ( TTree* )file->Get( "gst;1" );
    TH1F   * hists  = new TH1F[ t_files.size() ];

    string type = kBranchVarType.at( t_branch );
    string opt = "HIST";
    int    sizes[ t_files.size() ];
    int    nFiles = t_files.size();
    double cur_double;
    int    cur_int;
    double maxes[ t_files.size() ];
    double max;
    vector< double > branches[ t_files.size() ];

    for( int i = 0; i < t_files.size(); i++ ) {
        cout << "Retrieving information from file: `" << t_files[ i ] << "`, branch: `" << t_branch << "`." << endl;
        file = TFile::Open( t_files[ i ].c_str() );
        tree = ( TTree* )file->Get( "gst;1" );

        sizes[ i ] = tree->GetEntries();
        maxes[ i ] = 0;
             if( type == "int"    ) tree->SetBranchAddress( t_branch.c_str(), &cur_int    );
        else if( type == "double" ) tree->SetBranchAddress( t_branch.c_str(), &cur_double );
        else                        tree->SetBranchAddress( t_branch.c_str(), &cur_double );

        for( Int_t j = 0; j < sizes[ i ]; j++ ) {
            tree->GetEntry( j );
                 if( type == "int" )    branches[ i ].push_back( cur_int    );
            else if( type == "double" ) branches[ i ].push_back( cur_double );
            else                        branches[ i ].push_back( cur_double );

                 if( type == "int" )    { if( cur_int    > maxes[ i ] ) maxes[ i ] = cur_int   ; }
            else if( type == "double" ) { if( cur_double > maxes[ i ] ) maxes[ i ] = cur_double; }
            else                        { if( cur_double > maxes[ i ] ) maxes[ i ] = cur_double; }
        }
    }

    for( int i = 0; i < t_files.size(); i++ )
        if( maxes[ i ] > max ) max = maxes[ i ];

    for( int i = 0; i < t_files.size(); i++ ) {
        cout << "Making histogram for file: `" << t_files[ i ] << "`, branch: `" << t_branch << "`." << endl;
        hists[ i ] = TH1F( "", kTitles.at( t_branch ).c_str(), max + 1, 0, max );
        for( int j = 0; j < sizes[ i ]; j++ )
            hists[ i ].Fill( branches[ i ][ j ] );

        if( oFill ) { 
            hists[ i ].SetFillColorAlpha( kColors[ i ], 0.2 );
            hists[ i ].SetLineColorAlpha( kColors[ i ], 0.8 );
            hists[ i ].SetLineWidth     ( 3 );
        } else {
            hists[ i ].SetLineColorAlpha( kColors[ i ], 0.95 );
            hists[ i ].SetLineWidth     ( 4 );
        }
        if( oPercent ) {
            hists[ i ].Scale( 1 / double( branches[ i ].size() ) * 100 );
            hists[ i ].GetYaxis()->SetTitle( ( kYaxisTitles.at( t_branch ) + " [%]" ).c_str() );
        } else {
            hists[ i ].GetYaxis()->SetTitle( kYaxisTitles.at( t_branch ).c_str() );
        }
    }

    for( int i = 0; i < t_files.size() - 1; i++ ) {
        cout << "Drawing histogram for file: `" << t_files[ i ] << "`, branch: `" << t_branch << "`." << endl;
        hists[ i ].Draw( opt.c_str() );
        hists[ i ].Print( "base" );
        canvas->Modified();
        canvas->Update();
        opt = "Sames HIST";
    }
    cout << "Drawing histogram for file: `" << t_files.back() << "`, branch: `" << t_branch << "`." << endl;
    hists[ t_files.size() - 1 ].Draw( opt.c_str() );
    hists[ t_files.size() - 1 ].Print( "base" );
    canvas->Modified();
    canvas->Update();

    // cout << "here" << endl;
    // for( int i = 0; i < 999; i++ )
    //     int k = 0;
}
