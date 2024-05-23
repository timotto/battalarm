import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ChapterIntroductionComponent } from './chapter-introduction.component';

describe('ChapterIntroductionComponent', () => {
  let component: ChapterIntroductionComponent;
  let fixture: ComponentFixture<ChapterIntroductionComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ChapterIntroductionComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ChapterIntroductionComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
