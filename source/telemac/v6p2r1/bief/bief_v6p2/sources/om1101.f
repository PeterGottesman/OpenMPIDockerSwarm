!                    *****************
                     SUBROUTINE OM1101
!                    *****************
!
     &(OP ,  DM,TYPDIM,XM,TYPEXM,   DN,TYPDIN,XN,TYPEXN,   C,
     & NULONE,NELBOR,NBOR,NELMAX,NDIAG,NPTFR,NPTFRX)
!
!***********************************************************************
! BIEF   V6P1                                   21/08/2010
!***********************************************************************
!
!brief    OPERATIONS ON MATRICES.
!code
!+   M: P1 TRIANGLE
!+   N: BOUNDARY MATRIX
!+   D: DIAGONAL MATRIX
!+   C: CONSTANT
!+
!+   OP IS A STRING OF 8 CHARACTERS, WHICH INDICATES THE OPERATION TO BE
!+   PERFORMED ON MATRICES M AND N, D AND C.
!+
!+   THE RESULT IS MATRIX M.
!+
!+      OP = 'M=M+N   '  : ADDS N TO M
!+      OP = 'M=M+TN  '  : ADDS TRANPOSE OF N TO M
!
!code
!+  CONVENTION FOR THE STORAGE OF EXTRA-DIAGONAL TERMS:
!+
!+      XM(     ,1)  ---->  M(1,2)
!+      XM(     ,2)  ---->  M(1,3)
!+      XM(     ,3)  ---->  M(2,3)
!+      XM(     ,4)  ---->  M(2,1)
!+      XM(     ,5)  ---->  M(3,1)
!+      XM(     ,6)  ---->  M(3,2)
!
!history  J-M HERVOUET (LNHE)
!+        23/06/2008
!+        V5P9
!+
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        13/07/2010
!+        V6P0
!+   Translation of French comments within the FORTRAN sources into
!+   English comments
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        21/08/2010
!+        V6P0
!+   Creation of DOXYGEN tags for automated documentation and
!+   cross-referencing of the FORTRAN sources
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| C              |-->| A GIVEN CONSTANT USED IN OPERATION OP
!| DM             |<->| DIAGONAL OF M
!| DN             |-->| DIAGONAL OF N
!| NBOR           |-->| GLOBAL NUMBER OF BOUNDARY POINTS
!| NDIAG          |-->| NUMBER OF TERMS IN THE DIAGONAL
!| NELBOR         |-->| FOR THE KTH BOUNDARY EDGE, GIVES THE CORRESPONDING
!|                |   | ELEMENT.
!| NELMAX         |-->| MAXIMUM NUMBER OF ELEMENTS
!| NPTFR          |-->| NUMBER OF BOUNDARY POINTS
!| NPTFRX         |-->| MAXIMUM NUMBER OF BOUNDARY POINTS
!| NULONE         |-->| GOES WITH ARRAY NELBOR. NELBOR GIVES THE 
!|                |   | ADJACENT ELEMENT, NULONE GIVES THE LOCAL
!|                |   | NUMBER OF THE FIRST NODE OF THE BOUNDARY EDGE
!|                |   | I.E. 1, 2 OR 3 FOR TRIANGLES.
!| OP             |-->| OPERATION TO BE DONE (SEE ABOVE)
!| TYPDIM         |<->| TYPE OF DIAGONAL OF M:
!|                |   | TYPDIM = 'Q' : ANY VALUE
!|                |   | TYPDIM = 'I' : IDENTITY
!|                |   | TYPDIM = '0' : ZERO
!| TYPDIN         |<->| TYPE OF DIAGONAL OF N:
!|                |   | TYPDIN = 'Q' : ANY VALUE
!|                |   | TYPDIN = 'I' : IDENTITY
!|                |   | TYPDIN = '0' : ZERO
!| TYPEXM         |-->| TYPE OF OFF-DIAGONAL TERMS OF M:
!|                |   | TYPEXM = 'Q' : ANY VALUE
!|                |   | TYPEXM = 'S' : SYMMETRIC
!|                |   | TYPEXM = '0' : ZERO
!| TYPEXN         |-->| TYPE OF OFF-DIAGONAL TERMS OF N:
!|                |   | TYPEXN = 'Q' : ANY VALUE
!|                |   | TYPEXN = 'S' : SYMMETRIC
!|                |   | TYPEXN = '0' : ZERO
!| XM             |-->| OFF-DIAGONAL TERMS OF M
!| XN             |-->| OFF-DIAGONAL TERMS OF N
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_OM1101 => OM1101
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)             :: NELMAX,NDIAG,NPTFR,NPTFRX
      CHARACTER(LEN=8), INTENT(IN)    :: OP
      INTEGER, INTENT(IN)             :: NULONE(*),NELBOR(*),NBOR(*)
      DOUBLE PRECISION, INTENT(IN)    :: DN(*),XN(*)
      DOUBLE PRECISION, INTENT(INOUT) :: DM(*),XM(NELMAX,*)
      CHARACTER(LEN=1), INTENT(INOUT) :: TYPDIM,TYPEXM,TYPDIN,TYPEXN
      DOUBLE PRECISION, INTENT(IN)    :: C
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER K,IEL
!
      DOUBLE PRECISION Z(1)
!
      INTEGER CORNSY(3,2),CORSYM(3)
!
!-----------------------------------------------------------------------
!
      DATA CORNSY/ 1,3,5, 4,6,2 /
      DATA CORSYM/ 1,3,2        /
!
!-----------------------------------------------------------------------
!
      IF(OP(1:8).EQ.'M=M+N   ') THEN
!
        IF(TYPDIM.EQ.'Q'.AND.TYPDIM.EQ.'Q'.AND.NDIAG.GE.NPTFR) THEN
          CALL OVDB( 'X=X+Y   ' , DM , DN , Z , C , NBOR , NPTFR )
        ELSE
          IF (LNG.EQ.1) WRITE(LU,198) TYPDIM(1:1),OP(1:8),TYPDIN(1:1)
          IF (LNG.EQ.2) WRITE(LU,199) TYPDIM(1:1),OP(1:8),TYPDIN(1:1)
198       FORMAT(1X,'OM1101 (BIEF) : TYPDIM = ',A1,' NON PROGRAMME',
     &      /,1X,'POUR L''OPERATION : ',A8,' AVEC TYPDIN = ',A1)
199       FORMAT(1X,'OM1101 (BIEF) : TYPDIM = ',A1,' NOT IMPLEMENTED',
     &      /,1X,'FOR THE OPERATION : ',A8,' WITH TYPDIN = ',A1)
          CALL PLANTE(0)
          STOP
        ENDIF
!
        IF(TYPEXM(1:1).EQ.'Q'.AND.TYPEXN(1:1).EQ.'Q') THEN
!
!          CASE WHERE BOTH MATRICES ARE NONSYMMETRICAL
!
           IF(NCSIZE.GT.1) THEN
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               IF(IEL.GT.0) THEN
                 XM( IEL , CORNSY(NULONE(K),1) ) =
     &           XM( IEL , CORNSY(NULONE(K),1) ) + XN(K)
                 XM( IEL , CORNSY(NULONE(K),2) ) =
     &           XM( IEL , CORNSY(NULONE(K),2) ) + XN(K+NPTFRX)
               ENDIF
             ENDDO
           ELSE
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               XM( IEL , CORNSY(NULONE(K),1) ) =
     &         XM( IEL , CORNSY(NULONE(K),1) ) + XN(K)
               XM( IEL , CORNSY(NULONE(K),2) ) =
     &         XM( IEL , CORNSY(NULONE(K),2) ) + XN(K+NPTFRX)
             ENDDO
           ENDIF
!
        ELSEIF(TYPEXM(1:1).EQ.'Q'.AND.TYPEXN(1:1).EQ.'S') THEN
!
!          CASE WHERE M CAN BE ANYTHING AND N IS SYMMETRICAL
!
           IF(NCSIZE.GT.1) THEN
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               IF(IEL.GT.0) THEN
                 XM( IEL , CORNSY(NULONE(K),1) ) =
     &           XM( IEL , CORNSY(NULONE(K),1) ) + XN(K)
                 XM( IEL , CORNSY(NULONE(K),2) ) =
     &           XM( IEL , CORNSY(NULONE(K),2) ) + XN(K)
               ENDIF
             ENDDO
           ELSE
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               XM( IEL , CORNSY(NULONE(K),1) ) =
     &         XM( IEL , CORNSY(NULONE(K),1) ) + XN(K)
               XM( IEL , CORNSY(NULONE(K),2) ) =
     &         XM( IEL , CORNSY(NULONE(K),2) ) + XN(K)
             ENDDO
           ENDIF
!
        ELSEIF(TYPEXM(1:1).EQ.'S'.AND.TYPEXN(1:1).EQ.'S') THEN
!
!          CASE WHERE BOTH MATRICES ARE SYMMETRICAL
!
           IF(NCSIZE.GT.1) THEN
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               IF(IEL.GT.0) THEN
                 XM( IEL , CORSYM(NULONE(K)) ) =
     &           XM( IEL , CORSYM(NULONE(K)) ) + XN(K)
               ENDIF
             ENDDO
           ELSE
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               XM( IEL , CORSYM(NULONE(K)) ) =
     &         XM( IEL , CORSYM(NULONE(K)) ) + XN(K)
             ENDDO
           ENDIF
!
        ELSE
           IF (LNG.EQ.1) WRITE(LU,98) TYPEXM(1:1),OP(1:8),TYPEXN(1:1)
           IF (LNG.EQ.2) WRITE(LU,99) TYPEXM(1:1),OP(1:8),TYPEXN(1:1)
98         FORMAT(1X,'OM1101 (BIEF) : TYPEXM = ',A1,' NE CONVIENT PAS',
     &       /,1X,'POUR L''OPERATION : ',A8,' AVEC TYPEXN = ',A1)
99         FORMAT(1X,'OM1101 (BIEF) : TYPEXM = ',A1,' DOES NOT GO',
     &       /,1X,'FOR THE OPERATION : ',A8,' WITH TYPEXN = ',A1)
           CALL PLANTE(1)
           STOP
        ENDIF
!
!-----------------------------------------------------------------------
!
      ELSEIF(OP(1:8).EQ.'M=M+TN  ') THEN
!
        CALL OVDB( 'X=X+Y   ' , DM , DN , Z , C , NBOR , NPTFR )
!
        IF(TYPEXM(1:1).EQ.'Q'.AND.TYPEXN(1:1).EQ.'Q') THEN
!
!          CASE WHERE BOTH MATRICES ARE NONSYMMETRICAL
!
           IF(NCSIZE.GT.1) THEN
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               IF(IEL.GT.0) THEN
                 XM( IEL , CORNSY(NULONE(K),1) ) =
     &           XM( IEL , CORNSY(NULONE(K),1) ) + XN(K+NPTFRX)
                 XM( IEL , CORNSY(NULONE(K),2) ) =
     &           XM( IEL , CORNSY(NULONE(K),2) ) + XN(K)
               ENDIF
             ENDDO
           ELSE
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               XM( IEL , CORNSY(NULONE(K),1) ) =
     &         XM( IEL , CORNSY(NULONE(K),1) ) + XN(K+NPTFRX)
               XM( IEL , CORNSY(NULONE(K),2) ) =
     &         XM( IEL , CORNSY(NULONE(K),2) ) + XN(K)
             ENDDO
           ENDIF
!
        ELSEIF(TYPEXM(1:1).EQ.'Q'.AND.TYPEXN(1:1).EQ.'S') THEN
!
!          CASE WHERE N CAN BE ANYTHING AND N IS SYMMETRICAL
!
           IF(NCSIZE.GT.1) THEN
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               IF(IEL.GT.0) THEN
                 XM( IEL , CORNSY(NULONE(K),1) ) =
     &           XM( IEL , CORNSY(NULONE(K),1) ) + XN(K)
                 XM( IEL , CORNSY(NULONE(K),2) ) =
     &           XM( IEL , CORNSY(NULONE(K),2) ) + XN(K)
               ENDIF
             ENDDO
           ELSE
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               XM( IEL , CORNSY(NULONE(K),1) ) =
     &         XM( IEL , CORNSY(NULONE(K),1) ) + XN(K)
               XM( IEL , CORNSY(NULONE(K),2) ) =
     &         XM( IEL , CORNSY(NULONE(K),2) ) + XN(K)
             ENDDO
           ENDIF
!
        ELSEIF(TYPEXM(1:1).EQ.'S'.AND.TYPEXN(1:1).EQ.'S') THEN
!
!          CASE WHERE BOTH MATRICES ARE SYMMETRICAL
!
           IF(NCSIZE.GT.1) THEN
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               IF(IEL.GT.0) THEN
                 XM( IEL , CORSYM(NULONE(K)) ) =
     &           XM( IEL , CORSYM(NULONE(K)) ) + XN(K)
               ENDIF
             ENDDO
           ELSE
             DO K = 1 , NPTFR
               IEL = NELBOR(K)
               XM( IEL , CORSYM(NULONE(K)) ) =
     &         XM( IEL , CORSYM(NULONE(K)) ) + XN(K)
             ENDDO
           ENDIF
!
        ELSE
           IF (LNG.EQ.1) WRITE(LU,98) TYPEXM(1:1),OP(1:8),TYPEXN(1:1)
           IF (LNG.EQ.2) WRITE(LU,99) TYPEXM(1:1),OP(1:8),TYPEXN(1:1)
           CALL PLANTE(1)
           STOP
        ENDIF
!
!-----------------------------------------------------------------------
!
      ELSE
!
        IF (LNG.EQ.1) WRITE(LU,70) OP
        IF (LNG.EQ.2) WRITE(LU,71) OP
70      FORMAT(1X,'OM1101 (BIEF) : OPERATION INCONNUE : ',A8)
71      FORMAT(1X,'OM1101 (BIEF) : UNKNOWN OPERATION : ',A8)
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
