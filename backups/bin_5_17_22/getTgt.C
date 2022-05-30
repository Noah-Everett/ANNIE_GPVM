void getTgt( std::string gstFile ) {
    TFile* file = TFile::Open( gstFile.c_str() );

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

    for( Int_t i = 0; i < size; i++ )
    {
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

    cout << "[-]" << endl
         << " |---o code: 1000010010 [   H1] -----> number-of-initial-interactions = " << n1000010010 << endl
         << " |---o code: 1000060120 [  C12] -----> number-of-initial-interactions = " << n1000060120 << endl
         << " |---o code: 1000070140 [  N14] -----> number-of-initial-interactions = " << n1000070140 << endl
         << " |---o code: 1000080160 [  O16] -----> number-of-initial-interactions = " << n1000080160 << endl
         << " |---o code: 1000110230 [ Na23] -----> number-of-initial-interactions = " << n1000110230 << endl
         << " |---o code: 1000120240 [ Mg24] -----> number-of-initial-interactions = " << n1000120240 << endl
         << " |---o code: 1000130270 [ Al27] -----> number-of-initial-interactions = " << n1000130270 << endl
         << " |---o code: 1000140280 [ Si28] -----> number-of-initial-interactions = " << n1000140280 << endl
         << " |---o code: 1000180400 [ Ar40] -----> number-of-initial-interactions = " << n1000180400 << endl
         << " |---o code: 1000190390 [  K39] -----> number-of-initial-interactions = " << n1000190390 << endl
         << " |---o code: 1000200400 [ Ca40] -----> number-of-initial-interactions = " << n1000200400 << endl
         << " |---o code: 1000260560 [ Fe56] -----> number-of-initial-interactions = " << n1000260560 << endl;
}