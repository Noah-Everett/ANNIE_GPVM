int nDigits( int t_int )
{
    int count = 0;

    if( t_int == 0 )
        return 1;

    while( t_int != 0 ) {
        t_int = t_int / 10;
        ++count;
    }

    return count;
}

void getTgt( std::string nRun ) 
{
    std::string fileName = "gntp." + nRun + ".gst.root";
    
    TFile* file = TFile::Open( fileName.c_str() );
    TTree* tree = ( TTree* )file->Get( "gst;1" );
    
    const unsigned int size = tree->GetEntries();
    int tgt_cur;

    tree->SetBranchAddress( "tgt", &tgt_cur );

    int n1000010010 = 0;
    int n1000060120 = 0;
    int n1000070140 = 0;
    int n1000080160 = 0;
    int n1000110230 = 0;
    int n1000120240 = 0;
    int n1000130270 = 0;
    int n1000140280 = 0;
    int n1000180400 = 0;
    int n1000190390 = 0;
    int n1000200400 = 0;
    int n1000260560 = 0;

    for( Int_t i = 0; i < size; i++ ) {
        tree->GetEntry( i );

        if( tgt_cur == 1000010010 ) ++n1000010010;
        if( tgt_cur == 1000060120 ) ++n1000060120;
        if( tgt_cur == 1000070140 ) ++n1000070140;
        if( tgt_cur == 1000080160 ) ++n1000080160;
        if( tgt_cur == 1000110230 ) ++n1000110230;
        if( tgt_cur == 1000120240 ) ++n1000120240;
        if( tgt_cur == 1000130270 ) ++n1000130270;
        if( tgt_cur == 1000140280 ) ++n1000140280;
        if( tgt_cur == 1000180400 ) ++n1000180400;
        if( tgt_cur == 1000190390 ) ++n1000190390;
        if( tgt_cur == 1000200400 ) ++n1000200400;
        if( tgt_cur == 1000260560 ) ++n1000260560;
    }

    int max = 0;
    if( max < n1000010010 ) max = n1000010010;
    if( max < n1000060120 ) max = n1000060120;
    if( max < n1000070140 ) max = n1000070140;
    if( max < n1000080160 ) max = n1000080160;
    if( max < n1000110230 ) max = n1000110230;
    if( max < n1000120240 ) max = n1000120240;
    if( max < n1000130270 ) max = n1000130270;
    if( max < n1000140280 ) max = n1000140280;
    if( max < n1000180400 ) max = n1000180400;
    if( max < n1000190390 ) max = n1000190390;
    if( max < n1000200400 ) max = n1000200400;
    if( max < n1000260560 ) max = n1000260560;

    cout << "[-]" << endl
         << " |---o code: 1000010010 [   H1] -----> number-of-initial-interactions = " << n1000010010 << std::setw( nDigits( max ) + 2 - nDigits( n1000010010 ) ) << "(" << n1000010010 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000060120 [  C12] -----> number-of-initial-interactions = " << n1000060120 << std::setw( nDigits( max ) + 2 - nDigits( n1000060120 ) ) << "(" << n1000060120 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000070140 [  N14] -----> number-of-initial-interactions = " << n1000070140 << std::setw( nDigits( max ) + 2 - nDigits( n1000070140 ) ) << "(" << n1000070140 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000080160 [  O16] -----> number-of-initial-interactions = " << n1000080160 << std::setw( nDigits( max ) + 2 - nDigits( n1000080160 ) ) << "(" << n1000080160 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000110230 [ Na23] -----> number-of-initial-interactions = " << n1000110230 << std::setw( nDigits( max ) + 2 - nDigits( n1000110230 ) ) << "(" << n1000110230 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000120240 [ Mg24] -----> number-of-initial-interactions = " << n1000120240 << std::setw( nDigits( max ) + 2 - nDigits( n1000120240 ) ) << "(" << n1000120240 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000130270 [ Al27] -----> number-of-initial-interactions = " << n1000130270 << std::setw( nDigits( max ) + 2 - nDigits( n1000130270 ) ) << "(" << n1000130270 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000140280 [ Si28] -----> number-of-initial-interactions = " << n1000140280 << std::setw( nDigits( max ) + 2 - nDigits( n1000140280 ) ) << "(" << n1000140280 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000180400 [ Ar40] -----> number-of-initial-interactions = " << n1000180400 << std::setw( nDigits( max ) + 2 - nDigits( n1000180400 ) ) << "(" << n1000180400 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000190390 [  K39] -----> number-of-initial-interactions = " << n1000190390 << std::setw( nDigits( max ) + 2 - nDigits( n1000190390 ) ) << "(" << n1000190390 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000200400 [ Ca40] -----> number-of-initial-interactions = " << n1000200400 << std::setw( nDigits( max ) + 2 - nDigits( n1000200400 ) ) << "(" << n1000200400 / double( size ) * 100 << "%)" << endl
         << " |---o code: 1000260560 [ Fe56] -----> number-of-initial-interactions = " << n1000260560 << std::setw( nDigits( max ) + 2 - nDigits( n1000260560 ) ) << "(" << n1000260560 / double( size ) * 100 << "%)" << endl;
}
